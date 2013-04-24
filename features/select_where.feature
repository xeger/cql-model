Feature: WHERE constraint
  In order to build CQL WHERE constraints
  Developers pass blocks that call Ruby methods and operators
  So their queries are more idiomatic

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

  Scenario Outline: equality constraint
    When I call: <ruby>
    Then it should generate CQL: <cql>
  Examples:
    | ruby                            | cql                 |
    | select.where { name == 'Joe' }  | WHERE name = 'Joe'  |
    | select.where { age == 35 }      | WHERE age = 35      |
    | select.where { price == 29.95 } | WHERE price = 29.95 |
    | select.where { alive == true }  | WHERE alive = true  |
    | select.where { dead == false }  | WHERE dead = false  |

  Scenario Outline: non-string column names
    When I call: <ruby>
    Then it should generate CQL: <cql>
  Examples:
    | ruby                                            | cql                           |
    | select.where { int(123) == 'One Two Three' }    | WHERE "123" = 'One Two Three' |
    | select.where { float(42.42) == 'meaning' }      | WHERE "42.42" = 'meaning'     |
    | select.where { timestamp(8976) == true }        | WHERE "8976" = true           |
    | select.where { varint(123) == 'One Two Three' } | WHERE "123" = 'One Two Three' |

  Scenario Outline: membership constraint
    When I call: <ruby>
    Then it should generate CQL: <cql>
  Examples:
    | ruby                                    | cql                           |
    | select.where { name.in('Tom', 'Fred') } | WHERE name IN ('Tom', 'Fred') |
    | select.where { age.in(33, 34, 35) }     | WHERE age IN (33, 34, 35)     |
    | select.where { price.in(29.95) }        | WHERE price IN (29.95)        |
    | select.where { utf8('你好').in(29.95) }   | WHERE "你好" IN (29.95)         |

  Scenario Outline: inequality constraint
    When I call: <ruby>
    Then it should generate CQL: <cql>
  Examples:
    | ruby                           | cql                 |
    | select.where { price > 4.95 }  | WHERE price > 4.95  |
    | select.where { price < 4.95 }  | WHERE price < 4.95  |
    | select.where { name >= 'D' }   | WHERE name >= 'D'   |
    | select.where { age <= 30 }     | WHERE age <= 30     |
    | select.where { name != 'Joe' } | WHERE name != 'Joe' |

  Scenario Outline: compound expressions
    When I call: <ruby>
    Then it should generate CQL: <cql>
  Examples:
    | ruby                                                           | cql                                             |
    | select.where { name == 'Joe' }.and { age.in(33,34,35) }        | WHERE name = 'Joe' AND age IN (33, 34, 35)      |
    | select.where { name.in('Tom', 'Fred') }.and { price >  29.95 } | WHERE name IN ('Tom', 'Fred') AND price > 29.95 |

