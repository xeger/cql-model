require 'set'

module CQLModel::Query
  # @TODO docs
  class ExpressionBuilder < BasicObject
    OPERATORS = {:==    => '=',
                 :'!='  => '!=',
                 :'>'   => '>',
                 :'<'   => '<',
                 :'>='  => '>=',
                 :'<='  => '<=',
                 :'in'  => 'IN',
    }.freeze

    # @TODO docs
    def initialize(&block)
      @left     = nil
      @operator = nil
      @right    = nil

      instance_eval(&block) if block
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
        # Looking for a left operand
        @left = token
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
          ::Kernel.raise ParseError.new(
                           "Unacceptable token '#{token}'; expecting a CQL-compatible operator"
                         )
        end
      else
        ::Kernel.raise ParseError.new(
                         "Unacceptable token '#{token}'; the expression is " +
                           "already complete"
                       )
      end

      self
    end

    # @TODO docs
    def __build__
      if @left.nil? || @operator.nil? || @right.nil?
        ::Kernel.raise ParseError.new(
                         "Cannot build a CQL expression; the Ruby expression is incomplete " +
                           "(#{@left.inspect} #{@operator.inspect} #{@right.inspect})"
                       )
      else
        left  = ::CQLModel::Query::Util.cql_identifier(@left)
        op    = OPERATORS[@operator]
        right = ::CQLModel::Query::Util.cql_value(@right)
        "#{left} #{op} #{right}"
      end
    end
  end
end
