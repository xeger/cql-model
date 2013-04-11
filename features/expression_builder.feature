Feature: WHERE constraints
  In order to enhance productivity
  Developers write CQL WHERE constraints using Ruby expressions
  So their queries are more idiomatic

  Background:
    Given a CQL model definition:
    """
      class Widget
        include CQLModel::Model

        property :name, String
        property :age, Integer
        property :price, Float
        property :alive, Boolean
        property :dead, Boolean
      end
    """

  Scenario Outline: equality constraint
    When I call: <ruby>
    Then it should generate CQL: <cql>
  Examples:
    | ruby                     | cql                 |
    | where { name == 'Joe' }  | WHERE name = 'Joe'  |
    | where { age == 35 }      | WHERE age = 35      |
    | where { price == 29.95 } | WHERE price = 29.95 |
    | where { alive == true }  | WHERE alive = true  |
    | where { dead == false }  | WHERE dead = false  |

  Scenario Outline: non-string column names
    When I call: <ruby>
    Then it should generate CQL: <cql>
  Examples:
    | ruby                                     | cql                           |
    | where { int(123) == 'One Two Three' }    | WHERE "123" = 'One Two Three' |
    | where { float(42.42) == 'meaning' }      | WHERE "42.42" = 'meaning'     |
    | where { timestamp(8976) == true }        | WHERE "8976" = true           |
    | where { varint(123) == 'One Two Three' } | WHERE "123" = 'One Two Three' |

  Scenario Outline: membership constraint
    When I call: <ruby>
    Then it should generate CQL: <cql>
  Examples:
    | ruby                             | cql                           |
    | where { name.in('Tom', 'Fred') } | WHERE name IN ('Tom', 'Fred') |
    | where { age.in(33, 34, 35) }     | WHERE age IN (33, 34, 35)     |
    | where { price.in(29.95) }        | WHERE price IN (29.95)        |
    | where { utf8('你好').in(29.95) }   | WHERE "你好" IN (29.95)        |

  Scenario Outline: inequality constraint
    When I call: <ruby>
    Then it should generate CQL: <cql>
  Examples:
    | ruby                    | cql                 |
    | where { price > 4.95 }  | WHERE price > 4.95  |
    | where { price < 4.95 }  | WHERE price < 4.95  |
    | where { name >= 'D' }   | WHERE name >= 'D'   |
    | where { age <= 30 }     | WHERE age <= 30     |
    | where { name != 'Joe' } | WHERE name != 'Joe' |

  Scenario Outline: compound expressions
    When I call: <ruby>
    Then it should generate CQL: <cql>
  Examples:
    | ruby                                                    | cql                                             |
    | where { name == 'Joe' }.and { age.in(33,34,35) }        | WHERE name = 'Joe' AND age IN (33, 34, 35)      |
    | where { name.in('Tom', 'Fred') }.and { price >  29.95 } | WHERE name IN ('Tom', 'Fred') AND price > 29.95 |

