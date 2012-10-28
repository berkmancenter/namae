Feature: Parse a list of names
	As a hacker who works with Namae
	I want to be able to parse multiple names in a list

  @list
  Scenario: A list of names separated by 'and'
    When I parse the names "Plato and Archimedes and Publius Ovidius Naso"
    Then there should be 3 names
    And the names should be:
      | given           | family |
      | Plato           |        |
      | Archimedes      |        |
      | Publius Ovidius | Naso   |

  @list
  Scenario: A list of names separated by commas
    When I parse the names "Kernighan, Brian, Ritchie, Dennis and Donald Knuth"
    Then there should be 3 names
    And the names should be:
      | given  | family    |
      | Brian  | Kernighan |
      | Dennis | Ritchie   |
      | Donald | Knuth     |
    When I parse the names "Brian Kernighan, Dennis Ritchie and Donald Knuth"
    Then there should be 3 names
    And the names should be:
      | given  | family    |
      | Brian  | Kernighan |
      | Dennis | Ritchie   |
      | Donald | Knuth     |
    When I parse the names "Brian Kernighan, Dennis Ritchie, and Donald Knuth"
    Then there should be 3 names
    And the names should be:
      | given  | family    |
      | Brian  | Kernighan |
      | Dennis | Ritchie   |
      | Donald | Knuth     |
