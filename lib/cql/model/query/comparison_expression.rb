require 'set'

module Cql::Query
  # @TODO docs
  class ComparisonExpression < Expression
    # Operators allowed in a where-clause lambda
    OPERATORS = {
      :==   => '=',
      :'!=' => '!=',
      :'>'  => '>',
      :'<'  => '<',
      :'>=' => '>=',
      :'<=' => '<=',
      :'in' => 'IN',
    }.freeze

    # Methods used to escape CQL column names that aren't valid CQL identifiers
    TYPECASTS = [
      :ascii,
      :bigint,
      :blob,
      :boolean,
      :counter,
      :decimal,
      :double,
      :float,
      :int,
      :text,
      :timestamp,
      :uuid,
      :timeuuid,
      :varchar,
      :varint
    ].freeze

    # @TODO docs
    def initialize(*params, &block)
      @left     = nil
      @operator = nil
      @right    = nil

      instance_exec(*params, &block) if block
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

    TYPECASTS.each do |func|
      define_method(func) do |*args|
        __apply__(func, args)
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

          if (args.size > 1) || (token == :in)
            @right = args
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
        left  = ::Cql::Query.cql_identifier(@left)
        op    = OPERATORS[@operator]
        right = ::Cql::Query.cql_value(@right)
        "#{left} #{op} #{right}"
      end
    end
  end
end
