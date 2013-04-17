module CQLModel::Query

  # INSERT statements DSL
  # << An INSERT writes one or more columns to a record in a Cassandra column family. No results are returned.
  #    The first column name in the INSERT list must be the name of the column family key >>
  # (from: http://www.datastax.com/docs/1.1/references/cql/INSERT)
  #
  # Ex:
  # Model.create(:key => 'val', :col1 => 'value', :col2 => 42)                                         # Simple insert
  # Model.create(:key => 'val', :key2 => 64, :col1 => 'value', :col2 => 42)                            # Composite keys
  # Model.create(:key => 'val', :col => 'value').ttl(3600)                                             # TTL in seconds
  # Model.create(:key => 'val', :col => 'value').timestamp(1366057256324)                              # Milliseconds since epoch timestamp
  # Model.create(:key => 'val', :col => 'value').timestamp('2013-04-15 13:21:48')                      # ISO 8601 timestamp
  # Model.create(:key => 'val', :col => 'value').consistency('ONE')                                    # Custom consistency (default is 'LOCAL_QUORUM')
  # Model.create(:key => 'val', :col => 'value').ttl(3600).timestamp(1366057256324).consistency('ONE') # Multiple options
  class InsertStatement < MutationStatement

    # DSL for setting INSERT values
    #
    # @param [Hash] values Hash of column values indexed by column name
    def create(values)
      raise ArgumentError, "Cannot specify INSERT values twice" unless @values.nil?
      @values = values
      self
    end

    # Build CQL statement
    # Note: Do not check whether all keys are specified, let cassandra return an error if there is one
    #
    # @return [String] a CQL INSERT statement with suitable constraints and options
    #
    # @raise [CQLModel::MissingKeysError] if a primary key is not set in inserted values
    def to_s
      keys = @klass.primary_key.inject([]) { |h, k| h << [k, @values.delete(k)]; h }
      if keys.any? { |k| k[1].nil? }
        raise MissingKeysError.new("Missing primary key(s) in INSERT statement: #{keys.select { |k| k[1].nil? }.map(&:first).map(&:inspect).join(', ')}")
      end
      s = "INSERT INTO #{@klass.table_name} (#{keys.map { |k| k[0] }.join(', ')}, #{@values.keys.join(', ')})"
      s << " VALUES (#{keys.map { |k| ::CQLModel::Query.cql_value(k[1]) }.join(', ')}, #{@values.values.map { |v| ::CQLModel::Query.cql_value(v) }.join(', ')})"
      options = []
      options << "CONSISTENCY #{statement_consistency}"
      options << "TIMESTAMP #{@timestamp}" unless @timestamp.nil?
      options << "TTL #{@ttl}" unless @ttl.nil?
      s << " USING #{options.join(' AND ')}"
      s << ';'
    end

  end
end
