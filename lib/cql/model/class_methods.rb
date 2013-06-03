module Cql::Model::ClassMethods
  def self.extended(klass)
    klass.instance_eval do
      # The mutex is shared by all Cql::Model inheritors
      @@cql_model_mutex            ||= Mutex.new

      # Other attributes are tracked per-class
      @cql_table_name              ||= klass.name.split('::').last
      @cql_model_properties        ||= {}
      @cql_model_keys              ||= []
      @cql_model_read_consistency  ||= :local_quorum
      @cql_model_write_consistency ||= :local_quorum
    end
  end

  # Get or set the client connection used by this class.
  #
  # @param [optional, Cql::Client] new_client the new client to set
  # @return [Cql::Client] the current client
  def cql_client(new_client=nil)
    if new_client
      @@cql_model_mutex.synchronize do
        @cql_client = new_client
      end
    end

    @cql_client || ::Cql::Model.cql_client
  end

  # @TODO docs
  def table_name(new_name=nil)
    if new_name
      @@cql_model_mutex.synchronize do
        # Set the table name
        @cql_table_name = new_name
      end
    else
      # Get the table name
      @cql_table_name
    end
  end

  # @TODO docs
  def read_consistency(new_consistency=nil)
    if new_consistency
      @cql_model_read_consistency = new_consistency
    else
      @cql_model_read_consistency
    end
  end

  # @TODO docs
  def write_consistency(new_consistency=nil)
    if new_consistency
      @cql_model_write_consistency = new_consistency
    else
      @cql_model_write_consistency
    end
  end

  # Specify or get a primary key or a composite primary key
  #
  # @param key_vals [Symbol|Array<Symbol>] single key name or composite key names
  #
  # @return [Cql::Model] self
  def primary_key(*keys)
    if keys.empty?
      @cql_model_keys
    else
      @@cql_model_mutex.synchronize do
        @cql_model_keys = keys
      end
      self
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

      if @cql_model_properties.key?(name) && (@cql_model_properties[name] != definition)
        raise ArgumentError, "Property #{name} is already defined"
      end

      unless @cql_model_properties.key?(name)
        @cql_model_properties[name] = definition

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

  # @TODO docs
  def scope(name, &block)
    @@cql_model_mutex.synchronize do
      eigenclass = class <<self
        self
      end

      eigenclass.instance_eval do
        define_method(name.to_sym) do |*params|
          # @TODO use a prepared statement for speed
          self.select.where(*params, &block)
        end
      end
    end

    self
  end

  # Begin building a CQL SELECT statement.
  #
  # @param [Object] *params list of yield parameters for the block
  #
  # @example tell us how old Joe is
  #   Person.select.where { name == 'Joe' }.each { |person| puts person.age }
  def select(*params)
    Cql::Model::Query::SelectStatement.new(self).select(*params)
  end

  # Begin building a CQL INSERT statement.
  # @see Cql::Model::Query::InsertStatement
  #
  # @param [Hash] values Hash of column values indexed by column name
  # @return [Cql::Model::Query::InsertStatement] a query object to customize (timestamp, ttl, etc) or execute
  #
  # @example
  #   Person.create(:name => 'Joe', :age => 25).ttl(3600).execute
  def insert(values)
    Cql::Model::Query::InsertStatement.new(self).insert(values)
  end

  alias create insert

  # Start an UPDATE CQL statement
  # The method #keys must be called on the result before #execute
  # @see Cql::Model::Query::UpdateStatement
  #
  # @param [Hash] values Hash of column values indexed by column name, optional
  # @return [Cql::Model::Query::UpdateStatement] a query object to customize (keys, ttl, timestamp etc) then execute
  #
  # @example
  #   Person.update(:updated_at => Time.now.utc).keys(:name => ['joe', 'john', 'jane'])
  #   Person.update.ttl(3600).keys(:name => 'joe')
  def update(values={})
    Cql::Model::Query::UpdateStatement.new(self).update(values)
  end

  # @TODO docs
  def each_row(&block)
    Cql::Model::Query::SelectStatement.new(self).each_row(&block)
  end

  # @TODO docs
  def each(&block)
    Cql::Model::Query::SelectStatement.new(self).each(&block)
  end

  # Temporarily change the working keyspace.
  # Resets working keyspace back to default once.
  #
  # @param keyspace [String] temporary keyspace
  # @param block    [Proc]   code which should be called
  def with_keyspace(keyspace, &block)
    current_keyspace = cql_client.keyspace
    cql_client.use(keyspace)
    block.call
    cql_client.use(current_keyspace)
  end
end
