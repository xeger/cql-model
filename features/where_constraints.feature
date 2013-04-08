Feature: WHERE constraints
  In order to
  Developers should be able to express WHERE constraints in Ruby
  So their CQL queries are more idiomatic

  Scenario Outline: equality constraint
    Given a CQL model
    When I call: <ruby>
    Then it should generate CQL: <cql>

  Examples:
    | ruby                     | cql                |
    | where { name == 'Joe' }  | WHERE name = 'Joe' |
    | where { age == 35 }      | WHERE age = 35     |
    | where { price == 29.95 } | WHERE price = 29.95  |
    | where { alive == true }  | WHERE alive = true |
    | where { dead == false }  | WHERE dead = false |

  Scenario Outline: membership constraint
    Given a CQL model
    When I call: <ruby>
    Then it should generate CQL: <cql>

  Examples:
    | ruby                             | cql                           |
    | where { name.in('Tom', 'Fred') } | WHERE name IN ('Tom', 'Fred') |
    | where { age.in(33, 34, 35) }     | WHERE age IN (33, 34, 35)     |
    | where { price.in(29.95) }        | WHERE price IN (29.95)        |


  Scenario Outline: compound expressions
    Given a CQL model
    When I call: <ruby>
    Then it should generate CQL: <cql>

  Examples:
    | ruby                                                    | cql                                             |
    | where { name == 'Joe' }.and { age.in(33,34,35) }        | WHERE name = 'Joe' AND age IN (33, 34, 35)      |
    | where { name.in('Tom', 'Fred') }.and { price >  29.95 } | WHERE name IN ('Tom', 'Fred') AND price > 29.95 |
