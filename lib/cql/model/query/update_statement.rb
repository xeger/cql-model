module Cql::Model::Query

  # UPDATE statement DSL
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
    def initialize(klass, client=nil)
      super(klass, client)
      @where = []
    end

    # Create or append to the WHERE clause for this statement. The block that you pass will define the constraint
    # and any where() parameters will be forwarded to the block as yield parameters. This allows late binding of
    # variables in the WHERE clause, e.g. for prepared statements.
    # TODO examples
    # @see Expression
    def where(*params, &block)
      @where << ComparisonExpression.new(*params, &block)
      self
    end

    alias and where

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
      s = "UPDATE #{@klass.table_name}"

      options = []
      options << "TIMESTAMP #{@timestamp}" unless @timestamp.nil?
      options << "TTL #{@ttl}" unless @ttl.nil?
      s << " USING #{options.join(' AND ')}" if options.size > 0

      if @values.respond_to?(:map)
        if @values.respond_to?(:each_pair)
          # List of column names and values (or lambdas containing list/set/counter operations)
          pairs = @values.map do |n, v|
            if v.respond_to?(:call)
              "#{n} = #{UpdateExpression.new(&v).to_s}"
            else
              "#{n} = #{::Cql::Model::Query.cql_value(v)}"
            end
          end
          s << " SET #{pairs.join(', ')}"
        elsif @values.all? { |v| v.respond_to?(:call) }
          # Array of hash assignments
          assigns = @values.map { |v| "#{UpdateExpression.new(&v).to_s}" }
          s << " SET #{assigns.join(', ')}"
        end
      elsif @values.respond_to?(:call)
        # Simple hash assignment
        assign = UpdateExpression.new(&@values).to_s
        s << " SET #{assign}"
      end

      unless @where.empty?
        s << " WHERE " << @where.map { |w| w.to_s }.join(' AND ')
      end

      s << ';'

      s
    end
  end
end
