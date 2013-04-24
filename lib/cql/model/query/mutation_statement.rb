module Cql::Query

  # Common parent to InsertStatement and UpdateStatment
  # provide helpers for managing common DSL settings
  class MutationStatement < Statement

    # Instantiate statement
    #
    # @param [Class] klass
    # @param [Cql::Client] CQL client used to execute statement
    def initialize(klass, client=nil)
      super(klass, client)
      @values    = nil
      @ttl       = nil
      @timestamp = nil
    end

    # DSL for setting TTL value
    #
    # @param [Fixnum] ttl_value TTL value in seconds
    def ttl(ttl_value)
      raise ArgumentError, "Cannot specify TTL twice" unless @ttl.nil?
      @ttl = ttl_value
      self
    end

    # DSL for setting timestamp value
    #
    # @param [Fixnum|String] timestamp_value (number of milliseconds since epoch or ISO 8601 date time value)
    def timestamp(timestamp_value)
      raise ArgumentError, "Cannot specify timestamp twice" unless @timestamp.nil?
      @timestamp = timestamp_value
      self
    end

    # Execute this statement on the CQL client connection
    # INSERT statements do not return a result
    #
    # @return [true] always returns true
    def execute
      @client.execute(to_s)
      true
    end

  end

end

