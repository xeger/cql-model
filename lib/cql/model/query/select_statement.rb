module Cql::Model::Query

  # SELECT statement DSL
  # << A SELECT expression reads one or more records from a Cassandra column family and returns a result-set of rows.
  #    Each row consists of a row key and a collection of columns corresponding to the query. >>
  # (from: http://www.datastax.com/docs/1.1/references/cql/SELECT)
  #
  # Ex:
  # Model.select(:col1, :col2)
  # Model.select(:col1, :col2).where { name == 'Joe' }
  # Model.select(:col1, :col2).where { name == 'Joe' }.and { age.in(33,34,35) }
  # Model.select(:col1, :col2).where { name == 'Joe' }.and { age.in(33,34,35) }.order_by(:age).desc
  class SelectStatement < Statement

    # Instantiate statement
    #
    # @param [Class] klass Model class
    # @param [Cql::Client] CQL client used to execute statement
    def initialize(klass, client=nil)
      super(klass, client)
      @columns = nil
      @where   = []
      @order   = ''
      @limit   = nil
    end

    # Create or append to the WHERE clause for this statement. The block that you pass will define the constraint
    # and any where() parameters will be forwarded to the block as yield parameters. This allows late binding of
    # variables in the WHERE clause, e.g. for prepared statements.
    #
    # @param [Object] *params parameters to be forwarded to the block
    # @yield the block will be evaluated in the context of a ComparisonExpression to capture a CQL expression that will be appended to the WHERE clause
    #
    # @return [SelectStatement] always returns self
    #
    # @example find people named Joe
    #    where { name == "Joe" }
    #
    # @example find people older than 33 who are named Joe or Fred
    #    where { age > 33 }.and { name.in("Joe", "Fred") }
    #
    # @example find people older than 33
    #    where { age > 33 }
    #
    # @example find by a late-bound search term (e.g. for a named scope)
    #    where(age_chosen_by_user) { |chosen| age > chosen }
    #
    # @example find by a column name that is not a valid Ruby identifier
    #    where { timestamp(12345) == "logged in" }
    #
    # @see ComparisonExpression
    # @see Cql::Model::ClassMethods#scope
    def where(*params, &block)
      @where << ComparisonExpression.new(*params, &block)
      self
    end

    alias and where

    # Specify the order in which result rows should be returned.
    #
    # @param [Array] *params glob of column names (symbols, strings, or Ruby values that correspond to valid column names)
    # @return [SelectStatement] always returns self
    def order(*columns)
      raise ArgumentError, "Cannot specify ORDER BY twice" unless @order.empty?
      @order = ::Cql::Model::Query.cql_column_names(columns)
      self
    end

    alias order_by order

    # @TODO docs
    def asc
      raise ArgumentError, "Cannot specify ASC / DESC twice" if @order =~ /ASC|DESC$/
      raise ArgumentError, "Must specify ORDER BY before ASC" if @order.empty?
      @order << " ASC"
      self
    end

    # @TODO docs
    def desc
      raise ArgumentError, "Cannot specify ASC / DESC twice" if @order =~ /ASC|DESC$/
      raise ArgumentError, "Must specify ORDER BY before DESC" if @order.empty?
      @order << " DESC"
      self
    end

    # @TODO docs
    def limit(lim)
      raise ArgumentError, "Cannot specify LIMIT twice" unless @limit.nil?
      @limit = lim
      self
    end

    # @TODO docs
    def select(*columns)
      raise ArgumentError, "Cannot specify SELECT column names twice" unless @columns.nil?
      @columns = ::Cql::Model::Query.cql_column_names(columns)
      self
    end

    # @return [String] a CQL SELECT statement with suitable constraints and options
    def to_s
      s = "SELECT #{@columns || '*'} FROM #{@klass.table_name}"

      s << " USING CONSISTENCY " << (@consistency || @klass.write_consistency)

      unless @where.empty?
        s << " WHERE " << @where.map { |w| w.to_s }.join(' AND ')
      end

      s << " ORDER BY " << @order unless @order.empty?
      s << " LIMIT #{@limit}" unless @limit.nil?
      s << ';'
    end

    # Execute this SELECT statement on the CQL client connection and yield each row of the
    # result set as a raw-data Hash.
    #
    # @yield each row of the result set
    # @yieldparam [Hash] row a Ruby Hash representing the column names and values for a given row
    # @return [true] always returns true
    def execute(&block)
      @client.execute(to_s).each_row(&block).size

      true
    end

    alias each_row execute

    # Execute this SELECT statement on the CQL client connection and yield each row of the
    # as an instance of CQL::Model.
    #
    # @yield each row of the result set
    # @yieldparam [Hash] row a Ruby Hash representing the column names and values for a given row
    # @return [true] always returns true
    def each(&block)
      each_row do |row|
        block.call(@klass.new(row))
      end
    end
  end
end
