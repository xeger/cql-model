Feature: Consistency scenarios
  Native protocol supports consistency as another argument in execute()
  Model's execute should correctly set consistency

  Background:
    Given a CQL model definition:
    """
      class Timeline
        include Cql::Model

        property :user_id,  Integer
        property :tweet_id, Integer
        property :text,     String

        primary_key :user_id, :tweet_id
      end
    """

  Scenario: insert without consistency should be executed with default one
    When call: insert(:user_id => 42, :tweet_id => 13, :name => 'joe')
    Then it should should be executed with :local_quorum

  Scenario: insert with consistency should be executed with that one
    When call: insert(:user_id => 42, :tweet_id => 13, :name => 'joe').consistency(:one)
    Then it should should be executed with :one

  Scenario: insert with consistency and other options should be executed with that one
    When call: insert(:user_id => 42, :tweet_id => 13, :name => 'joe').consistency(:one).timestamp(1366057256324).ttl(3600)
    Then it should should be executed with :one

  Scenario: update without consistency should be executed with default one
    When call: update(:tweet_id => 13, :name => 'joe').where{ user_id == 42 }
    Then it should should be executed with :local_quorum

  Scenario: update with consistency should be executed with that one
    When call: update(:tweet_id => 13, :name => 'joe').where{ user_id == 42 }.consistency(:one)
    Then it should should be executed with :one

  Scenario: update with consistency and other options should be executed with that one
    When call: update(:tweet_id => 13, :name => 'joe').where{ user_id == 42 }.consistency(:one).timestamp(1366057256324).ttl(3600)
    Then it should should be executed with :one

  Scenario: select without consistency should be executed with default one
    When call: select.where {name == 'Joe'}
    Then it should should be executed with :local_quorum

  Scenario: select with consistency should be executed with that one
    When call: select.where {name == 'Joe'}.consistency(:one)
    Then it should should be executed with :one

  Scenario: select with consistency and other options should be executed with that one
    When call: select.where {name == 'Joe'}.order_by(:age).desc.consistency(:one)
    Then it should should be executed with :one

