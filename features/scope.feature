Feature: named scopes
  In order to enable CQL queries
  Developers have a class methods
  So their queries are more idiomatic

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

  Scenario: fixed where-clause
    When I call: not_joe
    Then it should generate CQL: WHERE name != 'Joe'

  Scenario: dynamic where-clause
    When I call: older_than(33)
    Then it should generate CQL: WHERE age > 33
