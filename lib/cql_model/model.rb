module CQLModel::Model
  class BadState < StandardError; end

  # Type alias for easy use with the property-declaration DSL; gets included into all implementers.
  UUID = Cql::Uuid

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

  # Write a property. Property names are column names, and can therefore take any data type
  # that a column name can take (integer, UUID, etc). Do not validate the name or type of
  # the property; it may be undeclared by this model, have a missing CQL column, or an
  # improper name/value for its column type.
  #
  # @param [Object] name
  # @param [Object] value
  def []=(name, value)
    @cql_updates          ||= {}
    @cql_updates[name]    = value
    @cql_properties[name] = value
  end

  # Attempt to save this record. Return false if anything goes wrong.
  #
  # @return [Boolean] true if save succeeded, false otherwise
  def save
    save!
    true
  rescue # only standard errors i.e. validation and friends
    false
  end

  # Save this record. Raise an exception if anything goes wrong.
  #
  # @return [true] if save succeeded
  # @raise [Exception] if a CQL issue occurred
  def save!
    if @cql_updates && !@cql_updates.empty?
      # TODO actually do this -- save, update, etc
      raise NotImplementedError
    else
      raise BadState, "Nothing to save; no properties were updated"
    end
  end
end

require 'cql_model/model/dsl'
