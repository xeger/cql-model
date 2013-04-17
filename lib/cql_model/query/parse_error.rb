module CQLModel::Query
  class ParseError < Exception
  end

  # Raised if an insert statement does not specify all the primary keys
  # or if an update statement does not specify any key (part of a composite primary key or a primary key)
  class MissingKeysError < Exception
  end
end
