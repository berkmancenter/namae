Feature: Parse a list of names
  As a hacker who works with Namae
  I want to be able to parse multiple names in a list

  Scenario: A list of names separated by 'and'
    When I parse the names "Plato and Archimedes and Publius Ovidius Naso"
    Then the names should be:
      | given           | family |
      | Plato           |        |
      | Archimedes      |        |
      | Publius Ovidius | Naso   |

  Scenario: A list of sort-order names separated by commas
    When I parse the names "Kernighan, Brian, Ritchie, Dennis, Knuth, Donald"
    Then the names should be:
      | given  | family    |
      | Brian  | Kernighan |
      | Dennis | Ritchie   |
      | Donald | Knuth     |
    Given a parser that prefers commas as separators
    When I parse the names "Kernighan, Brian, Ritchie, Dennis, Knuth, Donald"
    Then the names should be:
      | given  | family    |
      | Brian  | Kernighan |
      | Dennis | Ritchie   |
      | Donald | Knuth     |

  Scenario: A list of names separated by semicolons
    When I parse the names "John D. Smith; Jack R. Johnson; Emily Tanner"
    Then the names should be:
      | given   | family  |
      | John D. | Smith   |
      | Jack R. | Johnson |
      | Emily   | Tanner  |
    When I parse the names "Smith, John D.; Johnson, Jack R.; Tanner, Emily"
    Then the names should be:
      | given   | family  |
      | John D. | Smith   |
      | Jack R. | Johnson |
      | Emily   | Tanner  |

  Scenario: A list of sort-order names with initials separated by commas
    When I parse the names "Kernighan, B., Ritchie, D., Knuth, D."
    Then the names should be:
      | given | family    |
      | B.    | Kernighan |
      | D.    | Ritchie   |
      | D.    | Knuth     |

  Scenario: A list of mixed names separated by commas and 'and'
    When I parse the names "Kernighan, Brian, Ritchie, Dennis and Donald Knuth"
    Then the names should be:
      | given  | family    |
      | Brian  | Kernighan |
      | Dennis | Ritchie   |
      | Donald | Knuth     |

  Scenario: A list of mixed names separated by semicolons, commas and '&'
    Given a parser that prefers commas as separators
    When I parse the names "John D. Smith, Jack R. Johnson & Emily Tanner"
    Then the names should be:
      | given   | family  |
      | John D. | Smith   |
      | Jack R. | Johnson |
      | Emily   | Tanner  |
    When I parse the names "C. Foster; C. Hamel, C. Desroches"
    Then the names should be:
      | given | family    |
      | C.    | Foster    |
      | C.    | Hamel     |
      | C.    | Desroches |

  Scenario: A list of display-order names separated by commas and 'and'
    Given a parser that prefers commas as separators
    When I parse the names "Brian Kernighan, Dennis Ritchie, and Donald Knuth"
    Then the names should be:
      | given  | family    |
      | Brian  | Kernighan |
      | Dennis | Ritchie   |
      | Donald | Knuth     |

  Scenario: A list of names with initials separated by commas and '&'
    Given a parser that prefers commas as separators
    When I parse the names "G. Proctor, M. Cooper, P. Sanders & B. Malcom"
    Then the names should be:
      | given | family  |
      | G.    | Proctor |
      | M.    | Cooper  |
      | P.    | Sanders |
      | B.    | Malcom  |
    When I parse the names "G Proctor, M Cooper, PJ Sanders & B Malcom"
    Then the names should be:
      | given | family  |
      | G     | Proctor |
      | M     | Cooper  |
      | PJ    | Sanders |
      | B     | Malcom  |

  Scenario: A list of names with particles separated by commas
    Given I want to include particles in the family name
    And a parser that prefers commas as separators
    When I parse the names "Di Proctor, M., von Cooper, P."
    Then the names should be:
      | given | family     |
      | M.    | Di Proctor |
      | P.    | von Cooper |
    When I parse the names "Di Proctor, M, von Cooper, P"
    Then the names should be:
      | given | family     |
      | M     | Di Proctor |
      | P     | von Cooper |

  Scenario: A list of names with two consecutive accented characters
    Given I want to include particles in the family name
    And a parser that prefers commas as separators
    When I parse the names "Çakıroğlu, Ü., Başıbüyük, B."
    Then the names should be:
      | given | family    |
      | Ü.    | Çakıroğlu |
      | B.    | Başıbüyük |

  Scenario: A list of names with trailing titles
    When I parse the names "John Smith, MD and Jane Doe, PhD"
    Then the names should be:
      | given | family | title |
      | John  | Smith  | MD    |
      | Jane  | Doe    | PhD   |

  Scenario: A list of names with internet handles
    When I parse the names "Alice and @jdoe and 42jdoe"
    Then the names should be:
      | given  |
      | Alice  |
      | @jdoe  |
      | 42jdoe |
