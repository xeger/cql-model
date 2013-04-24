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
      end
    """

  Scenario: select all columns
    Given a pending cuke

  Scenario: select some columns
    Given a pending cuke

  Scenario: limit results
    Given a pending cuke

  Scenario: sort results ascending
    Given a pending cuke

  Scenario: sort results descending
    Given a pending cuke

  Scenario: specify read consistency
    Given a pending cuke

  Scenario: select each row
    Given a pending cuke

  Scenario: select each model
    Given a pending cuke
