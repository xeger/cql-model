module CQLModel::Query

  class Statement

    # Initialize instance variables common to all statements
    #
    # @param [Class] klass Model class
    # @param [CQLModel::Client] client used to connect to Cassandra
    def initialize(klass, client)
      @klass       = klass
      @client      = client || klass.cql_client
      @consistency = nil
    end

    def to_s
      raise NotImplementedError, "Subclass responsibility"
    end

    def execute
      raise NotImplementedError, "Subclass responsibility"
    end

    # Specify consistency level to use when executing statemnt
    # See http://www.datastax.com/docs/1.0/dml/data_consistency
    # Defaults to :local_quorum
    #
    # @param [String] consistency One of 'ANY', 'ONE', 'QUORUM', 'LOCAL_QUORUM', 'EACH_QUORUM', 'ALL' as of Cassandra 1.0
    # @return [String] consistency value
    def consistency(consist)
      raise ArgumentError, "Cannot specify USING CONSISTENCY twice" unless @consistency.nil?
      @consistency = consist
      self
    end

    # CQL query consistency level
    # Default to 'LOCAL_QUORUM'
    #
    # @return [String] CQL query consistency
    def statement_consistency
      @consistency || 'LOCAL_QUORUM'
    end

    alias using_consistency consistency
  end

end
