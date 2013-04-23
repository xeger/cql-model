module CQLModel::Model::DSL
  def self.extended(klass)
    klass.instance_eval do
      @@cql_model_mutex             ||= Mutex.new
      @@cql_table_name              ||= klass.name
      @@cql_model_properties        ||= {}
      @@cql_model_keys              ||= []
      @@cql_model_read_consistency  ||= 'LOCAL_QUORUM'
      @@cql_model_write_consistency ||= 'LOCAL_QUORUM'
    end
  end

  # @TODO docs
  def cql_client
    @cql_client || ::CQLModel::Model.cql_client
  end

  # @TODO docs
  def cql_client=(client)
    @cql_client = client
  end

  # @TODO docs
  def table_name(new_name=nil)
    if new_name
      @@cql_model_mutex.synchronize do
        # Set the table name
        @@cql_table_name = new_name
      end
    else
      # Get the table name
      @@cql_table_name
    end
  end

  # @TODO docs
  def read_consistency(new_consistency=nil)
    if new_consistency
      @@cql_model_read_consistency = new_consistency
    else
      @@cql_model_read_consistency
    end
  end

  # @TODO docs
  def write_consistency(new_consistency=nil)
    if new_consistency
      @@cql_model_write_consistency = new_consistency
    else
      @@cql_model_write_consistency
    end
  end

  # @TODO docs
  def property(name, type, opts={})
    definition = {}

    # If the user specified the name as a symbol, then they automatically get
    # a reader and writer because the property has a predictable, fixed column
    # name.
    if name.is_a?(Symbol)
      definition[:reader] = opts[:reader] || name
      definition[:writer] = opts[:writer] || "#{definition[:reader]}=".to_sym
      name                = name.to_s
    end

    @@cql_model_mutex.synchronize do
      definition[:type] = type

      if @@cql_model_properties.key?(name) && (@@cql_model_properties[name] != definition)
        raise ArgumentError, "Property #{name} is already defined"
      end

      unless @@cql_model_properties.key?(name)
        @@cql_model_properties[name] = definition

        __send__(:define_method, definition[:reader]) do
          self[name]
        end if definition[:reader]

        __send__(:define_method, definition[:writer]) do |value|
          self[name] = value
        end if definition[:writer]
      end
    end

    self
  end

  # Specify or get a primary key or a composite primary key
  #
  # @param key_vals [Symbol|Array<Symbol>] single key name or composite key names
  #
  # @return [CQLModel::Model] self
  def primary_key(*keys)
    if keys.empty?
      @@cql_model_keys
    else
      @@cql_model_mutex.synchronize do
        @@cql_model_keys = keys
      end
      self
    end
  end

  # @TODO docs
  def scope(name, &block)
    @@cql_model_mutex.synchronize do
      eigenclass = class <<self
        self
      end

      eigenclass.instance_eval do
        define_method(name.to_sym) do |*params|
          # @TODO use a prepared statement for speed
          self.where(*params, &block)
        end
      end
    end

    self
  end

  # Begin building a CQL SELECT statement. The methods that the block calls will define the where constraint,
  # and any where() parameters will be forwarded to the block as yield parameters. This allows late binding of
  # variables in the WHERE clause, e.g. for prepared statements.
  #
  # @param [Object] *params list of yield parameters for the block
  # @yield [Object] evaluates the block in the context of the select statement, allowing its builder methods to be called
  # @return [CQLModel::Query::SelectStatement] a query object to customize (order, limit, etc) or execute
  #
  # @example tell us how old Joe is
  #   Person.where { name == 'Joe' }.each { |person| puts person.age }
  def where(*params, &block)
    if params.size > 0
      # Dynamic WHERE clause (that contains runtime replacement parameters)
      CQLModel::Query::SelectStatement.new(self).where(*params, &block)
    else
      # Static WHERE clause
      CQLModel::Query::SelectStatement.new(self).where(*params, &block)
    end
  end

  # Begin buildling a CQL INSERT statement.
  # @see CQLModel::Query::InsertStatement
  #
  # @param [Hash] values Hash of column values indexed by column name
  # @return [CQLModel::Query::InsertStatement] a query object to customize (timestamp, ttl, etc) or execute
  #
  # @example
  #   Person.create(:name => 'Joe', :age => 25).ttl(3600).execute
  def insert(values)
    CQLModel::Query::InsertStatement.new(self).insert(values)
  end

  alias create insert

  # Start an UPDATE CQL statement
  # The method #keys must be called on the result before #execute
  # @see CQLModel::Query::UpdateStatement
  #
  # @param [Hash] values Hash of column values indexed by column name, optional
  # @return [CQLModel::Query::UpdateStatement] a query object to customize (keys, ttl, timestamp etc) then execute
  #
  # @example
  #   Person.update(:updated_at => Time.now.utc).keys(:name => ['joe', 'john', 'jane'])
  #   Person.update.ttl(3600).keys(:name => 'joe')
  def update(values={})
    CQLModel::Query::UpdateStatement.new(self).update(values)
  end

  # @TODO docs
  def each_row(&block)
    CQLModel::Query::SelectStatement.new(self).each_row(&block)
  end

  # @TODO docs
  def each(&block)
    CQLModel::Query::SelectStatement.new(self).each(&block)
  end
end
