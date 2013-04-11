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

        scope(:joe)        { name == 'Joe' }
        scope(:not_joe)    { name != 'Joe' }
      end
    """

  Scenario: fixed where-clause
    When I call: joe
    Then it should generate CQL: WHERE name = 'Joe'
    When I call: not_joe
    Then it should generate CQL: WHERE name != 'Joe'
