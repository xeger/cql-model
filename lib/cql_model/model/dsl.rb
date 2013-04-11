module CQLModel::Model::DSL
  def self.extended(klass)
    klass.instance_eval do
      @@cql_model_mutex      ||= Mutex.new
      @@cql_table_name       ||= klass.name
      @@cql_model_properties ||= {}
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
  def property(name, type, opts={})
    definition = {}

    # If the user specified the name as a symbol, then they automatically get
    # a reader and writer because the property has a predictable, fixed column
    # name.
    if name.is_a?(Symbol)
      definition[:reader] = opts[:reader] || name
      definition[:writer] = opts[:writer] || "#{definition[:reader]}=".to_sym
      name = name.to_s
    end

    @@cql_model_mutex.synchronize do
      definition[:type]   = type

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

  # @TODO docs
  def scope(name, &block)
    @@cql_model_mutex.synchronize do
      eigenclass = class <<self
        self
      end

      eigenclass.instance_eval do
        define_method(name.to_sym) do |*params|
          # @TODO use a prepared statement for speed
          self.where(*params,&block)
        end
      end
    end

    self
  end

  # @TODO docs
  def where(*params, &block)
    if params.size > 0
      # Dynamic WHERE clause (that contains runtime replacement parameters)
      CQLModel::Query::SelectStatement.new(self).where(*params, &block)
    else
      # Static WHERE clause
      CQLModel::Query::SelectStatement.new(self).where(*params, &block)
    end
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
