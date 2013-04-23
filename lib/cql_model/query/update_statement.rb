module CQLModel::Query

  # UPDATE statements DSL
  # << An UPDATE writes one or more columns to a record in a Cassandra column family. No results are returned.
  #    Row/column records are created if they do not exist, or overwritten if they do exist >>
  # (from http://www.datastax.com/docs/1.1/references/cql/UPDATE)
  #
  # Note: user a hash with a single key :value to update counter columns using the existing counter value:
  #   update(:id => 12, :counter => { :value => 'counter + 1' })
  #
  # E.g.:
  # Model.update(:id => '123', :col => 'value', :counter => { :value => 'counter + 2' })
  # Model.update(:id => ['123', '456'], :col => 'value')
  # Model.update(:id => '123', :col => 'value').ttl(3600)
  # Model.update(:id => '123', :col => 'value').timestamp(1366057256324)
  # Model.update(:id => '123', :col => 'value').timestamp('2013-04-15 13:21:48')
  # Model.update(:id => '123', :col => 'value').consistency('ONE')
  # Model.update(:id => ['123', '456'], :col => 'value', :counter => 'counter + 2').ttl(3600).timestamp(1366057256324).consistency('ONE')
  #
  # Can also be used on Model instances, e.g.:
  # @model.update(:col => 'value', :counter => 'counter + 2')
  # @model.update_all_by('name', :col => 'value') # 'name' must be part of the table composite key
  class UpdateStatement < MutationStatement

    # DSL for setting UPDATE values
    #
    # @param [Hash] values Hash of column values or column update expression indexed by column name
    def update(values)
      raise ArgumentError, "Cannot specify UPDATE values twice" unless @values.nil?
      @values = values
      self
    end

    # @return [String] a CQL UPDATE statement with suitable constraints and options
    def to_s
      key = @values.keys.detect { |k| @klass.primary_key.include?(k) }
      if key.nil?
        raise MissingKeysError.new("No key in UPDATE statement, please use at least one of: #{@klass.primary_key.map(&:inspect).join(', ')}")
      end
      key_values = @values.delete(key)
      s = "UPDATE #{@klass.table_name}"
      options = []
      options << "CONSISTENCY #{@consistency || @klass.write_consistency}"
      options << "TIMESTAMP #{@timestamp}" unless @timestamp.nil?
      options << "TTL #{@ttl}" unless @ttl.nil?
      s << " USING #{options.join(' AND ')}"
      s << " SET #{@values.to_a.map { |n, v| "#{n} = #{::CQLModel::Query.cql_value(v)}" }.join(', ')}"
      s << " WHERE #{key} "
      s << (key_values.is_a?(Array) ? "IN (#{key_values.map { |v| ::CQLModel::Query.cql_value(v) }.join(', ')})" : "= #{::CQLModel::Query.cql_value(key_values)}")
      s << ';'

      s
    end
  end
end
