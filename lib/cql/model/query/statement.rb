module Cql::Model::Query

  class Statement

    # Initialize instance variables common to all statements
    #
    # @param [Class] klass Model class
    # @param [Cql::Client] client used to connect to Cassandra
    def initialize(klass, client)
      @klass       = klass
      @client      = client || klass.cql_client
      @consistency = nil
    end

    # Build a string representation of this CQL statement, suitable for execution by a CQL client.
    # @return [String]
    def to_s
      raise NotImplementedError, "Subclass responsibility"
    end

    # Execute this CQL statement. Return value and parameters vary for each derived class.
    # @see SelectStatement#execute
    # @see InsertStatement#execute
    # @see UpdateStatement#execute
    def execute
      raise NotImplementedError, "Subclass responsibility"
    end

    # Specify consistency level to use when executing statemnt
    # See http://www.datastax.com/docs/1.0/dml/data_consistency
    # Defaults to :local_quorum
    #
    # @param consist [Symbol] consistency level as one of the [:any, :one, :two, :three, :quorum, :all, :local_quorum, :each_quorum]
    #                         Also it can be string: 'ANY', 'ONE', 'TWO', 'THREE', 'QUORUM', 'LOCAL_QUORUM', 'EACH_QUORUM', 'ALL'
    # @return [String] consistency value
    def consistency(consist)
      raise ArgumentError, "Cannot specify CONSISTENCY twice" unless @consistency.nil?
      consist = consist.downcase.to_sym if consist.class == String
      raise ArgumentError, "Unknown Consistency level '#{consist}'" unless [:any, :one, :two, :three, :quorum, :all, :local_quorum, :each_quorum].include?(consist)
      @consistency = consist
      self
    end

    alias using_consistency consistency
  end

end
