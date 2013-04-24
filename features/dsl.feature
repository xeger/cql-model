Feature: CQL model DSL
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
    Given a pending cuke

  Scenario: named scope with fixed where-clause
    When I call: not_joe
    Then it should generate CQL: WHERE name != 'Joe'

  Scenario: named scope with dynamic where-clause
    When I call: older_than(33)
    Then it should generate CQL: WHERE age > 33

  Scenario: overridden table name
    Given a pending cuke
