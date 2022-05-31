Feature: Parse names with a pronoun
  As a hacker who works with Namae
  I want to be able to parse names with a pronoun

  @names @pronoun
  Scenario: Names with a male gender pronoun
    When I parse the names "Max Power (he/him)"
    Then the names should be:
      | given      | family  | pronoun  |
      | Max        | Power   | (he/him) |

  @names @pronoun
  Scenario: Names with a female gender pronoun
    When I parse the names "Jane Doe (she/her)"
    Then the names should be:
      | given      | family  | pronoun  |
      | Jane       | Doe     | (she/her)|

  