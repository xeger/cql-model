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
    When I call: update(:tweet_id => 13, :name => 'joe').where { user_id == 42 }
    Then it should generate CQL: UPDATE <model_class> USING CONSISTENCY LOCAL_QUORUM SET tweet_id = 13, name = 'joe' WHERE user_id = 42

  Scenario: simple update, first component of composite key to appear in values should be used in WHERE clause
    When I call: update(:name => 'joe', :user_id => 42).where { tweet_id == 13 }
    Then it should generate CQL: UPDATE <model_class> USING CONSISTENCY LOCAL_QUORUM SET name = 'joe', user_id = 42 WHERE tweet_id = 13

  Scenario: update counter column
    When I call: update(:counter => { :value => 'counter + 2' }).where { user_id == 42 }
    Then it should generate CQL: UPDATE <model_class> USING CONSISTENCY LOCAL_QUORUM SET counter = counter + 2 WHERE user_id = 42

  Scenario Outline: update with options
    When I call: <ruby>
    Then it should generate CQL that includes: <cql>
  Examples:
    | ruby                                                                                               | cql                                                                |
    | update(:name => 'joe').where {user_id == 42}.consistency('ONE')                                    | USING CONSISTENCY ONE SET                                          |
    | update(:name => 'joe').where {user_id == 42}.timestamp(1366057256324)                              | USING CONSISTENCY LOCAL_QUORUM AND TIMESTAMP 1366057256324 SET     |
    | update(:name => 'joe').where {user_id == 42}.ttl(3600)                                             | USING CONSISTENCY LOCAL_QUORUM AND TTL 3600 SET                    |
    | update(:name => 'joe').where {user_id == 42}.consistency('ONE').timestamp(1366057256324).ttl(3600) | USING CONSISTENCY ONE AND TIMESTAMP 1366057256324 AND TTL 3600 SET |
