module CQLModel::Query
  # CQL single quote character.
  SQ         = "'"

  # CQL single-quote escape sequence.
  SQSQ       = "''"

  # CQL double-quote character.
  DQ         = '"'

  # CQL double-quote escape.
  DQDQ       = '""'

  # Valid CQL identifier (can be used as a column name without double-quoting)
  IDENTIFIER = /[a-z][a-z0-9_]*/i

  module_function

  # Transform a list of symbols or strings into CQL column names. Performs no safety checks!!
  def cql_column_names(list)
    if list.empty?
      '*'
    else
      list.join(', ')
    end
  end

  # Transform a Ruby object into its CQL identifier representation.
  #
  # @TODO more docs
  #
  def cql_identifier(value)
    # TODO UUID, Time, ...
    case value
    when Symbol, String
      if value =~ IDENTIFIER
        value.to_s
      else
        "#{DQ}#{value.gsub(DQ, DQDQ)}#{DQ}"
      end
    when Numeric, TrueClass, FalseClass
      "#{DQ}#{cql_value(value)}#{DQ}"
    else
      raise ParseError, "Cannot convert #{value.class} to a CQL identifier"
    end
  end

  # Transform a Ruby object into its CQL literal value representation. A literal value is anything
  # that can appear in a CQL statement as a key or column value (but not column NAME; see
  # #cql_identifier to convert values to column names).
  #
  # @param value [String,Numeric,Boolean, Array]
  # @return [String] the CQL equivalent of value
  #
  # When used as a key or column value, CQL supports the following kinds of literal value:
  #  * unquoted identifier (treated as a string value)
  #  * string literal
  #  * integer number
  #  * UUID
  #  * floating-point number
  #  * boolean true/false
  #
  # When used as a column name, any value that is not a valid identifier MUST BE ENCLOSED IN
  # DOUBLE QUOTES. This method does not handle the double-quote escaping; see #cql_identifier
  # for that.
  #
  # @see #cql_identifier
  # @see http://www.datastax.com/docs/1.1/references/cql/cql_lexicon#keywords-and-identifiers
  def cql_value(value)
    # TODO UUID, Time, ...
    case value
    when String
      "#{SQ}#{value.gsub(SQ, SQSQ)}#{SQ}"
    when Numeric, TrueClass, FalseClass
      value.to_s
    when Hash
      # Used by UPDATE statements to refer to counter columns
      value = value[:value]
      raise ParseError, "Cannot convert #{value.inspect} to a CQL value" unless value.is_a?(String)
      value
    else
      if value.respond_to?(:map)
        '(' + value.map { |v| cql_value(v) }.join(', ') + ')'
      else
        raise ParseError, "Cannot convert #{value.class} to a CQL value"
      end
    end
  end
end

require 'cql_model/query/parse_error'
require 'cql_model/query/expression'
require 'cql_model/query/statement'
require 'cql_model/query/mutation_statement'
require 'cql_model/query/select_statement'
require 'cql_model/query/insert_statement'
require 'cql_model/query/update_statement'
