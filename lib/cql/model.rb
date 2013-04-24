require 'thread'
require 'cql'

module Cql::Model
  # Raised if the user calls DSL that cannot generate valid CQL
  class SyntaxError < Exception; end

  # Raised if an insert statement does not specify all the primary keys
  # or if an update statement does not specify any key (part of a composite primary key or a primary key)
  class MissingKey < Exception; end

  # Type aliases for use with the property-declaration DSL.
  Uuid = Cql::Uuid
  UUID = Uuid

  # Type alias for use with the property-declaration DSL.
  Boolean = TrueClass

end

require 'cql/model/query'
require 'cql/model/class_methods'
require 'cql/model/instance_methods'

module Cql::Model
  def self.included(klass)
    klass.__send__(:extend, Cql::Model::ClassMethods)
    klass.__send__(:include, Cql::Model::InstanceMethods)
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
end
