module CQLModel::Model
  # Raised if the user calls DSL that cannot generate valid CQL
  class SyntaxError < Exception; end

  # Raised if an insert statement does not specify all the primary keys
  # or if an update statement does not specify any key (part of a composite primary key or a primary key)
  class MissingKey < Exception; end

  # Type alias for use with the property-declaration DSL.
  UUID = Cql::Uuid

  # Type alias for use with the property-declaration DSL.
  Boolean = TrueClass

  def self.included(klass)
    klass.__send__(:extend, CQLModel::Model::DSL)
  end

  # Master client connection shared by every model that doesn't bother to set its own.
  # Defaults to a localhost connection with no default keyspace; every query must be
  # wrapped in a using_keyspace.
  #
  # @return [Cql::Client] the current client
  def self.cql_client
    @cql_client ||= Cql::Client.new
    @cql_client.start! unless @cql_client.connected?
    @cql_client
  end

  # Change the client connection. Will not affect any in-progress queries.
  #
  # @param [Cql::Client] client
  # @return [Cql::Client] the new client
  def self.cql_client=(client)
    @cql_client = client
  end

  # Instantiate a new instance of this model. Do not validate the contents of
  # cql_properties; it may contain properties that aren't declared by this model, that have
  # a missing CQL column, or an improper name/value for their column type.
  #
  # @param [Hash] cql_properties typed hash of all properties associated with this model
  def initialize(cql_properties=nil)
    @cql_properties = cql_properties || {}
  end

  # Read a property. Property names are column names, and can therefore take any data type
  # that a column name can take (integer, UUID, etc).
  #
  # @param [Object] name
  # @return [Object] the value of the specified column, or nil
  def [](name)
    @cql_properties[name]
  end

  # Start an INSERT CQL statement to update model
  # @see CQLModel::Query::InsertStatement
  #
  # @param [Hash] values Hash of column values indexed by column name, optional
  # @return [CQLModel::Query::InsertStatement] a query object to customize (ttl, timestamp etc) or execute
  #
  # @example
  #   joe.update(:age => 35).execute
  #   joe.update.ttl(3600).execute
  #   joe.update(:age => 36).ttl(7200).consistency('ONE').execute
  def update(values={})
    key_vals = self.class.primary_key.inject({}) { |h, k| h[k] = @cql_properties[k]; h }
    CQLModel::Query::UpdateStatement.new(self.class).update(values.merge(key_vals))
  end

  # Start an UPDATE CQL statement to update all models with given key
  # This can update multiple models if the key is part of a composite key
  # Updating all models with given (different) key values can be done using the '.update' class method
  # @see CQLModel::Query::UpdateStatement
  #
  # @param [Symbol|String] key Name of key used to select models to be updated
  # @param [Hash] values Hash of column values indexed by column names, optional
  # @return [CQLModel::Query::UpdateStatement] a query object to customize (ttl, timestamp etc) or execute
  #
  # @example
  #   joe.update_all_by(:name, :age => 25).execute # Set all joe's age to 25
  #   joe.update_all_by(:name).ttl(3600).execute # Set all joe's TTL to one hour
  def update_all_by(key, values={})
    CQLModel::Query::UpdateStatement.new(self.class).update(values.merge({ key => @cql_properties[key.to_s] }))
  end

end

require 'cql_model/model/dsl'
