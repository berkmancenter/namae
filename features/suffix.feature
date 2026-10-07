Feature: Parse names with a suffix
  As a hacker who works with Namae
  I want to be able to parse names with a suffix

  Scenario Outline: Names with a suffix
    When I parse the name "<name>"
    Then the parts should be:
      | given   | family   | suffix   |
      | <given> | <family> | <suffix> |

    Examples:
      | name                  | given | family  | suffix |
      | Griffey, Jr., Ken     | Ken   | Griffey | Jr.    |
      | Ken Griffey, Jr.      | Ken   | Griffey | Jr.    |
      | Griffey, Ken, Jr.     | Ken   | Griffey | Jr.    |
      | Griffey, Ken Jr.      | Ken   | Griffey | Jr.    |
      | Ken Griffey Jr.       | Ken   | Griffey | Jr.    |
      | John Smith 3rd        | John  | Smith   | 3rd    |
      | John Smith Jnr        | John  | Smith   | Jnr    |
      | Henry VIII            | Henry |         | VIII   |
      | Henry 8th             | Henry |         | 8th    |
      | Smith, John, Jr., PhD | John  | Smith   | Jr.    |

  Scenario: A list of names with suffixes
    When I parse the names "Griffey, Jr., Ken and Ken Griffey, Jr. and Griffey, Ken, Jr. and Ken Griffey Jr."
    Then the names should be:
      | given | family  | suffix |
      | Ken   | Griffey | Jr.    |
      | Ken   | Griffey | Jr.    |
      | Ken   | Griffey | Jr.    |
      | Ken   | Griffey | Jr.    |
