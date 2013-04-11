module CQLModel::Query
  # @TODO docs
  class SelectStatement
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

    # @TODO docs
    def where(&block)
      @where << Expression.new(&block)
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

    # @TODO docs
    def each_row(&block)
      @client.execute(self.to_s).each_row(&block).size
    end

    # @TODO docs
    def each(&block)
      each_row do |row|
        block.call(@klass.new(row))
      end
    end
  end
end
