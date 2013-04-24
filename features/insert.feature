Feature: INSERT statement
  In order to build INSERT statements
  Developers call class-level DSL methods
  So they can insert data into Cassandra

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

  Scenario: simple insert
    When I call: insert(:user_id => 42, :tweet_id => 13, :name => 'joe')
    Then it should generate CQL: INSERT INTO <model_class> (user_id, tweet_id, name) VALUES (42, 13, 'joe') USING CONSISTENCY LOCAL_QUORUM

  Scenario: simple insert, keys should always be first in CQL independently of Ruby's internal hash ordering
    When I call: insert(:name => 'joe', :tweet_id => 13, :user_id => 42)
    Then it should generate CQL: INSERT INTO <model_class> (user_id, tweet_id, name) VALUES (42, 13, 'joe') USING CONSISTENCY LOCAL_QUORUM

  Scenario Outline: insert with missing primary key(s) should fail and error message shoud list missing key(s)
    When I call: <ruby>
    Then it should error with: <error>
  Examples:
    | ruby                                    | error                                          |
    | insert(:user_id => 42, :name => 'joe')  | Cql::Model::MissingKey, tweet_id          |
    | insert(:tweet_id => 42, :name => 'joe') | Cql::Model::MissingKey, user_id           |
    | insert(:name => 'joe')                  | Cql::Model::MissingKey, user_id.*tweet_id |

  Scenario Outline: insert with options
    When I call: <ruby>
    Then it should generate CQL: <cql>
  Examples:
    | ruby                                                                                                          | cql                                                            |
    | insert(:user_id => 42, :tweet_id => 13, :name => 'joe').consistency('ONE')                                    | USING CONSISTENCY ONE                                          |
    | insert(:user_id => 42, :tweet_id => 13, :name => 'joe').timestamp(1366057256324)                              | USING CONSISTENCY LOCAL_QUORUM AND TIMESTAMP 1366057256324     |
    | insert(:user_id => 42, :tweet_id => 13, :name => 'joe').ttl(3600)                                             | USING CONSISTENCY LOCAL_QUORUM AND TTL 3600                    |
    | insert(:user_id => 42, :tweet_id => 13, :name => 'joe').consistency('ONE').timestamp(1366057256324).ttl(3600) | USING CONSISTENCY ONE AND TIMESTAMP 1366057256324 AND TTL 3600 |
