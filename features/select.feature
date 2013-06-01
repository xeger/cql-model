Feature: SELECT statement
  In order to build SELECT statements
  Developers call class-level DSL methods
  So they can read data from Cassandra

  Background:
    Given a CQL model definition:
    """
      class Widget
        include Cql::Model

        property :name, String
        property :age, Integer
        property :price, Float
        property :alive, Boolean
        property :dead, Boolean

        primary_key :name
      end
    """

  Scenario: select all columns
    When I call: select.where {name == 'Joe'}
    Then it should generate CQL that includes: SELECT * FROM Widget

  Scenario: select some columns
    When I call: select(:age, :price).where {name == 'Joe'}
    Then it should generate CQL that includes: SELECT age, price FROM Widget

  Scenario: limit results
    When I call: select.where {name == 'Joe'}.limit(10)
    Then it should generate CQL that includes: LIMIT 10

  Scenario: sort results
    When I call: select.where {name == 'Joe'}.order_by(:age)
    Then it should generate CQL that includes: ORDER BY age

  Scenario: sort results ascending
    When I call: select.where {name == 'Joe'}.order_by(:age).asc
    Then it should generate CQL that includes: ORDER BY age ASC

  Scenario: sort results descending
    When I call: select.where {name == 'Joe'}.order_by(:age).desc
    Then it should generate CQL that includes: ORDER BY age DESC

  Scenario: select each row
    Given a pending cuke

  Scenario: select each model
    Given a pending cuke
