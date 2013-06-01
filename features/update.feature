Feature: UPDATE statement
  In order to build UPDATE statements
  Developers call class-level DSL methods
  So they can update data in Cassandra

  Background:
    Given a CQL model definition:
    """
      class Timeline
        include Cql::Model

        property :user_id,  Integer
        property :tweet_id, Integer
        property :text,     String
        property :counter,  Integer

        primary_key :user_id, :tweet_id
      end
    """

  Scenario: simple update with partial primary key constraint
    When I call: update(:tweet_id => 13, :name => 'joe').where { user_id == 42 }
    Then it should generate CQL: UPDATE <model_class> SET tweet_id = 13, name = 'joe' WHERE user_id = 42

  Scenario: simple update with partial primary key constraint
    When I call: update(:name => 'joe', :user_id => 42).where { tweet_id == 13 }
    Then it should generate CQL: UPDATE <model_class> SET name = 'joe', user_id = 42 WHERE tweet_id = 13

  Scenario: increment counter
    When I call: update(:counter => lambda { counter + 2 }).where { user_id == 42 }
    Then it should generate CQL: UPDATE <model_class> SET counter = counter + 2 WHERE user_id = 42

  Scenario: decrement counter
    When I call: update(:counter => lambda { counter - 1 }).where { user_id == 42 }
    Then it should generate CQL: UPDATE <model_class> SET counter = counter - 1 WHERE user_id = 42

  Scenario: add to set
    When I call: update(:grades => lambda { grades + Set.new([1,2,3]) }).where { user_id == 42 }
    Then it should generate CQL: UPDATE <model_class> SET grades = grades + {1, 2, 3} WHERE user_id = 42

  Scenario: remove from set
    When I call: update(:grades => lambda { grades - Set.new([1,2,3]) }).where { user_id == 42 }
    Then it should generate CQL: UPDATE <model_class> SET grades = grades - {1, 2, 3} WHERE user_id = 42

  Scenario: add to list
    When I call: update(:grades => lambda { grades + [1,2,3] }).where { user_id == 42 }
    Then it should generate CQL: UPDATE <model_class> SET grades = grades + [1, 2, 3] WHERE user_id = 42

  Scenario: remove from list
    When I call: update(:grades => lambda { grades - [1,2,3] }).where { user_id == 42 }
    Then it should generate CQL: UPDATE <model_class> SET grades = grades - [1, 2, 3] WHERE user_id = 42

  Scenario: add to map
    When I call: update(:scores => lambda { scores + {'math' => 7, 'science' => 9} }).where { user_id == 42 }
    Then it should generate CQL: UPDATE <model_class> SET scores = scores + {'math': 7, 'science': 9} WHERE user_id = 42

  Scenario: set one map element
    When I call: update(lambda { scores['english'] = 3 }).where { user_id == 42 }
    Then it should generate CQL: UPDATE <model_class> SET scores['english'] = 3 WHERE user_id = 42

  Scenario: set many map elements
    When I call: update([lambda { scores['english'] = 3 }, lambda { scores['history'] = 7 }]).where { user_id == 42 }
    Then it should generate CQL: UPDATE <model_class> SET scores['english'] = 3, scores['history'] = 7 WHERE user_id = 42

  Scenario Outline: update with options
    When I call: <ruby>
    Then it should generate CQL that includes: <cql>
  Examples:
    | ruby                                                                            | cql                                            |
    | update(:name => 'joe').where {user_id == 42}.timestamp(1366057256324)           | USING TIMESTAMP 1366057256324 SET              |
    | update(:name => 'joe').where {user_id == 42}.ttl(3600)                          | USING TTL 3600 SET                             |
    | update(:name => 'joe').where {user_id == 42}.timestamp(1366057256324).ttl(3600) | USING TIMESTAMP 1366057256324 AND TTL 3600 SET |
