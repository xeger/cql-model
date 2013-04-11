Feature: CQL model DSL
  In order to provide an ORM wrapper for CQL
  Developers can decorate their models with DSL class method calls
  So the models act like real objects

  Background:
    Given a CQL model definition:
    """
      class Person
        include CQLModel::Model

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
