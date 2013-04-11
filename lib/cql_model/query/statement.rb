module CQLModel::Query
  class Statement
    def to_s
      raise NotImplementedError, "Subclass responsibility"
    end

    def execute
      raise NotImplementedError, "Subclass responsibility"
    end
  end
end