require 'set'

module Cql::Model::Query
  # @TODO docs
  class UpdateExpression < Expression
    # Operators allowed in an update lambda
    OPERATORS = {
      :+   => '+',
      :-   => '-',
      :[]= => true # special treatment in #__build__
    }.freeze

    # @TODO docs
    def initialize(&block)
      @left     = nil
      @operator = nil
      @right    = nil

      instance_exec(&block) if block
    end

    # @TODO docs
    def to_s
      __build__
    end

    # @TODO docs
    def inspect
      __build__
    end

    # This is where the magic happens. Ensure all of our operators are overloaded so they call
    # #apply and contribute to the CQL expression that will be built.
    OPERATORS.keys.each do |op|
      define_method(op) do |*args|
        __apply__(op, args)
      end
    end

    # @TODO docs
    def method_missing(token, *args)
      __apply__(token, args)
    end

    private

    # @TODO docs
    def __apply__(token, args)
      if @left.nil?
        if args.empty?
          # A well-behaved CQL identifier (column name that is a valid Ruby method name)
          @left = token
        elsif args.length == 1
          # A CQL typecast (column name that is an integer, float, etc and must be wrapped in a decorator)
          @left = args.first
        else
          ::Kernel.raise ::Cql::Model::SyntaxError.new(
                           "Unacceptable token '#{token}'; expected a CQL identifier or typecast")
        end
      elsif @operator.nil?
        # Looking for an operator + right operand
        if OPERATORS.keys.include?(token)
          @operator = token

          if (token == :[]=)
            @right = args # the right-hand argument of []= is a (key, value) pair
          else
            @right = args.first
          end
        else
          ::Kernel.raise ::Cql::Model::SyntaxError.new(
                           "Unacceptable token '#{token}'; expected a CQL-compatible operator")
        end
      else
        ::Kernel.raise ::Cql::Model::SyntaxError.new(
                         "Unacceptable token '#{token}'; the expression is " +
                           "already complete")
      end

      self
    end

    # @TODO docs
    def __build__
      if @left.nil? || @operator.nil? || @right.nil?
        ::Kernel.raise ::Cql::Model::SyntaxError.new(
                         "Cannot build a CQL expression; the Ruby expression is incomplete " +
                           "(#{@left.inspect}, #{@operator.inspect}, #{@right.inspect})")
      else
        left = ::Cql::Model::Query.cql_identifier(@left)
        case @operator
        when :[]=
          key = ::Cql::Model::Query.cql_value(@right[0], context=:update)
          val = ::Cql::Model::Query.cql_value(@right[1], context=:update)
          "#{left}[#{key}] = #{val}"
        else
          op    = OPERATORS[@operator]
          right = ::Cql::Model::Query.cql_value(@right, context=:update)
          "#{left} #{op} #{right}"
        end
      end
    end
  end
end
