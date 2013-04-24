Feature: class-level DSL for schema declarations
  In order to define the CQL schema
  Developers call class-level DSL methods
  So the framework knows about their models

  Background:
    Given a CQL model definition:
    """
      class Person
        include Cql::Model

        property :name, String
        property :age,  Integer

        scope(:not_joe)    { name != 'Joe' }
        scope(:older_than) { |x| age > x   }
      end
    """

  Scenario: declare properties
    When I call: property :gender, String
    Then the model should respond to gender

  Scenario: named scope with fixed where-clause
    When I call: not_joe
    Then it should generate CQL: WHERE name != 'Joe'

  Scenario: named scope with dynamic where-clause
    When I call: older_than(33)
    Then it should generate CQL: WHERE age > 33

  Scenario: inferred table name
    When I call: table_name
    Then it should return: "Person"

  Scenario: inferred table name inside a namespace
    Given a CQL model definition:
    """
      module WeirdStuff
        class WeirdModel
          include Cql::Model
        end
      end
    """
    When I call: table_name
    Then it should return: "WeirdModel"

  Scenario: overridden table name
    When I call: table_name "WeirdOverriddenTableName"
    And I call: table_name
    Then it should return: "WeirdOverriddenTableName"

  Scenario: overridden CQL client
    When I call: cql_client "ThisIsNotReallyAClient"
    And I call: cql_client
    Then it should return: "ThisIsNotReallyAClient"
