Feature: Parse names with a title
  As a hacker who works with Namae
  I want to be able to parse names with a title

  Scenario Outline: Names with a title
    When I parse the name "<name>"
    Then the parts should be:
      | given   | family   | title   |
      | <given> | <family> | <title> |

    @wip
    Examples: Known limitations
      | name                  | given   | family   | title     |
      | Bernado Franecki, PhD | Bernado | Franecki | PhD       |
      | Dr. John Smith, Ph.D. | John    | Smith    | Dr. Ph.D. |
