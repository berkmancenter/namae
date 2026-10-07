Feature: Parse names reported in GitHub issues
  As a hacker who works with Namae
  I want to be sure that names reported as issues stay fixed

  Scenario Outline: Reported names
    When I parse the name "<name>"
    Then the parts should be:
      | given   | particle   | family   | suffix   | title   | appellation   |
      | <given> | <particle> | <family> | <suffix> | <title> | <appellation> |

    Examples: #6 Trailing titles after a comma
      | name                   | given    | particle | family   | suffix | title | appellation |
      | Bernardo Franecki, PhD | Bernardo |          | Franecki |        | PhD   |             |

    Examples: #29 Appellations and titles in sort order
      | name              | given | particle | family | suffix | title | appellation |
      | Smith, Mr. John   | John  |          | Smith  |        |       | Mr.         |
      | Smith, Prof. John | John  |          | Smith  |        | Prof. |             |

    Examples: #32 Appellations with suffixes, titles and names that look like titles
      | name                               | given           | particle | family     | suffix | title  | appellation |
      | Mr. Joseph Edward Mulligan, III    | Joseph Edward   |          | Mulligan   | III    |        | Mr.         |
      | Mr. William Charles Richardson,III | William Charles |          | Richardson | III    |        | Mr.         |
      | Mr. John Stanley Lord Jr.          | John Stanley    |          | Lord       | Jr.    |        | Mr.         |
      | Ms. Bettina Cantor Hollo           | Bettina Cantor  |          | Hollo      |        |        | Ms.         |
      | Mr. Bernard Pastor                 | Bernard         |          | Pastor     |        |        | Mr.         |
      | Mr. Maj Vasigh                     | Maj             |          | Vasigh     |        |        | Mr.         |
      | Mr. Richard Elder Crum             | Richard Elder   |          | Crum       |        |        | Mr.         |
      | Lt Col Edwin D Selby               | Edwin D         |          | Selby      |        | Lt Col |             |

    Examples: #44 Esq. after a comma
      | name                     | given    | particle | family  | suffix | title | appellation |
      | JAMES W GOVIN, ESQ       | JAMES W  |          | GOVIN   |        | ESQ   |             |
      | BRYANT H DUNIVAN JR, ESQ | BRYANT H |          | DUNIVAN | JR     | ESQ   |             |

  Scenario: #39 Capitalized particles in the family name
    Given I want to include particles in the family name
    When I parse the name "Carlos De Silva"
    Then the parts should be:
      | given  | particle | family   |
      | Carlos |          | De Silva |

  Scenario Outline: Reported names with particles, suffixes and nicknames
    When I parse the name "<name>"
    Then the parts should be:
      | given   | particle   | family   | suffix   | appellation   | nick   |
      | <given> | <particle> | <family> | <suffix> | <appellation> | <nick> |

    Examples: #14 and #43 Suffix before the sort-order comma
      | name                      | given     | particle | family | suffix | appellation | nick        |
      | Gump Jr., Bubba B.        | Bubba B.  |          | Gump   | Jr.    |             |             |
      | Gump II, Bubba            | Bubba     |          | Gump   | II     |             |             |
      | LEWIS JR, DOMINIC G       | DOMINIC G |          | LEWIS  | JR     |             |             |
      | Gump, Bubba "Shrimp King" | Bubba     |          | Gump   |        |             | Shrimp King |

    Examples: #28, #50 and #32 Particles with suffixes
      | name                             | given         | particle | family       | suffix | appellation | nick |
      | Ronder von Buran VI              | Ronder        | von      | Buran        | VI     |             |      |
      | Mr. Carlos Manuel de la Cruz III | Carlos Manuel | de la    | Cruz         | III    | Mr.         |      |
      | Mr. Michael von Krogh Foster II  | Michael       | von      | Krogh Foster | II     | Mr.         |      |

    Examples: #30 and #32 Nicknames before the name or in parentheses
      | name                           | given        | particle | family | suffix | appellation | nick  |
      | 'John' Johnathan Q. Public     | Johnathan Q. |          | Public |        |             | John  |
      | Mr. Jonathan H (Jason) Warner  | Jonathan H   |          | Warner |        | Mr.         | Jason |
      | Mr. Gillis E (Beau) Powell III | Gillis E     |          | Powell | III    | Mr.         | Beau  |
      | Mr. Michael S ('Mike') Hagen   | Michael S    |          | Hagen  |        | Mr.         | Mike  |

  Scenario: #50 Particles with suffixes and titles
    When I parse the name "Dr. Bob Van Barker Jr."
    Then the parts should be:
      | given | particle | family | suffix | title |
      | Bob   | Van      | Barker | Jr.    | Dr.   |

  Scenario Outline: #45 Pronouns
    When I parse the name "<name>"
    Then the parts should be:
      | given   | family   | nick   | pronouns   |
      | <given> | <family> | <nick> | <pronouns> |

    Examples:
      | name                        | given | family  | nick  | pronouns       |
      | Max Power (he/him, er/ihm)  | Max   | Power   |       | he/him, er/ihm |
      | Max Power (er/ihm)          | Max   | Power   |       | er/ihm         |
      | Sam (Sammy) Doe (they/them) | Sam   | Doe     | Sammy | they/them      |
      | Lisa (Her) Simpson          | Lisa  | Simpson | Her   |                |

  Scenario: Adding pronouns
    Given I add "elle" to the pronouns
    And I add "iel" to the pronouns
    When I parse the name "Alex Martin (elle/iel)"
    Then the parts should be:
      | given | family | pronouns |
      | Alex  | Martin | elle/iel |
