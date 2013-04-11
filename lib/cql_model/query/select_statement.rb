module CQLModel::Query
  # @TODO docs
  class SelectStatement < Statement
    # @TODO docs
    def initialize(klass, client=nil)
      @klass       = klass
      @client      = client || klass.cql_client
      @columns     = nil
      @where       = []
      @order       = ''
      @limit       = nil
      @consistency = nil
    end

    # @TODO docs
    def where(*params, &block)
      @where << Expression.new(*params, &block)
      self
    end

    alias and where

    # @TODO docs
    def order(*columns)
      raise ArgumentError, "Cannot specify ORDER BY twice" unless @order.empty?
      @order = Query.cql_column_names(columns)
      self
    end

    alias order_by order

    # @TODO docs
    def asc
      raise ArgumentError, "Cannot specify ASC / DESC twice" if @order =~ /ASC|DESC$/
      raise ArgumentError, "Must specify ORDER BY before ASC" if @order.empty?
      @order << " ASC"
    end

    # @TODO docs
    def desc
      raise ArgumentError, "Cannot specify ASC / DESC twice" if @order =~ /ASC|DESC$/
      raise ArgumentError, "Must specify ORDER BY before DESC" if @order.empty?
      @order << " DESC"
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
      @columns = Query.cql_column_names(columns)
      self
    end

    # @TODO docs
    def consistency(consist)
      raise ArgumentError, "Cannot specify USING CONSISTENCY twice" unless @consistency.nil?
      @consistency = consist
    end

    alias using_consistency consistency

    # @return [String] a CQL SELECT statement with suitable constraints and options
    def to_s
      s = "SELECT #{@columns || '*'} FROM #{@klass.table_name}"
      s << " USING CONSISTENCY " << @consistency unless @consistency.nil?
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
