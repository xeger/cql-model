Feature: UPDATE statement
  In order to build UPDATE statements
  Developers call class-level DSL methods
  So they can update data in Cassandra

  Background:
    Given a CQL model definition:
    """
      class Timeline
        include CQLModel::Model

        property :user_id,  Integer
        property :tweet_id, Integer
        property :text,     String
        property :counter,  Integer

        primary_key :user_id, :tweet_id
      end
    """

  Scenario: simple update
    When I call: update(:user_id => 42, :tweet_id => 13, :name => 'joe')
    Then it should generate CQL: UPDATE <model_class> USING CONSISTENCY LOCAL_QUORUM SET tweet_id = 13, name = 'joe' WHERE user_id = 42

  Scenario: simple update, first component of composite key to appear in values should be used in WHERE clause
    When I call: update(:name => 'joe', :tweet_id => 13, :user_id => 42)
    Then it should generate CQL: UPDATE <model_class> USING CONSISTENCY LOCAL_QUORUM SET name = 'joe', user_id = 42 WHERE tweet_id = 13

  Scenario: update counter column
    When I call: update(:user_id => 42, :counter => { :value => 'counter + 2' })
    Then it should generate CQL: UPDATE <model_class> USING CONSISTENCY LOCAL_QUORUM SET counter = counter + 2 WHERE user_id = 42

  Scenario: update with no primary key should fail and error message shoud list primary key(s)
    When I call: update(:name => 'joe')
    Then it should error with: CQLModel::Query::MissingKeysError, user_id.*tweet_id

  Scenario Outline: update with options
    When I call: <ruby>
    Then it should generate CQL that includes: <cql>
  Examples:
    | ruby                                                            | cql                                                            |
    | update(:user_id => 42, :name => 'joe').consistency('ONE')       | USING CONSISTENCY ONE SET                                      |
    | update(:user_id => 42, :name => 'joe').timestamp(1366057256324) | USING CONSISTENCY LOCAL_QUORUM AND TIMESTAMP 1366057256324 SET |
    | update(:user_id => 42, :name => 'joe').ttl(3600)                | USING CONSISTENCY LOCAL_QUORUM AND TTL 3600 SET                |
    | update(:user_id => 42, :name => 'joe').consistency('ONE').timestamp(1366057256324).ttl(3600) | USING CONSISTENCY ONE AND TIMESTAMP 1366057256324 AND TTL 3600 SET |
