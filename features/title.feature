Feature: Parse names with a title
  As a hacker who works with Namae
  I want to be able to parse names with a title

  Scenario Outline: Names with a title
    When I parse the name "<name>"
    Then the parts should be:
      | given   | family   | title   | appellation   |
      | <given> | <family> | <title> | <appellation> |

    Examples: Titles before and after the name
      | name                  | given   | family   | title     | appellation |
      | Bernado Franecki, PhD | Bernado | Franecki | PhD       |             |
      | Dr. John Smith, Ph.D. | John    | Smith    | Dr. Ph.D. |             |
      | John Smith MD, PhD    | John    | Smith    | MD PhD    |             |
      | John Smith, M.D.      | John    | Smith    | M.D.      |             |
      | Jane Doe, Esq.        | Jane    | Doe      | Esq.      |             |
      | Gen. George Patton    | George  | Patton   | Gen.      |             |
      | Hon. Jane Doe         | Jane    | Doe      | Hon.      |             |

    Examples: Family names that are also titles
      | name           | given    | family | title | appellation |
      | Georg Cantor   | Georg    | Cantor |       |             |
      | Cantor, Georg  | Georg    | Cantor |       |             |
      | Mary Ann Elder | Mary Ann | Elder  |       |             |
      | Walter Lord    | Walter   | Lord   |       |             |

    Examples: Given names that are also titles
      | name             | given  | family    | title | appellation |
      | Md Rahman        | Md     | Rahman    |       |             |
      | Rahman, Md       | Md     | Rahman    |       |             |
      | Pastor Maldonado | Pastor | Maldonado |       |             |
      | Deacon Jones     | Deacon | Jones     |       |             |
      | Elder Hernández  | Elder  | Hernández |       |             |
      | Gen Hoshino      | Gen    | Hoshino   |       |             |
      | Maj Sjöwall      | Maj    | Sjöwall   |       |             |
      | Major Taylor     | Major  | Taylor    |       |             |

    Examples: Appellations that look like titles
      | name         | given | family | title | appellation |
      | Fr. Müller   |       | Müller |       | Fr.         |
      | Mx Sam Smith | Sam   | Smith  |       | Mx          |

  Scenario Outline: Adding titles
    Given I add "<word>" to the <list>
    When I parse the name "<name>"
    Then the parts should be:
      | given   | family   | title   |
      | <given> | <family> | <title> |

    Examples: Titles left out of the defaults because they double as names
      | list            | word   | name                  | given   | family  | title  |
      | titles          | Cantor | Cantor David Cohen    | David   | Cohen   | Cantor |
      | titles          | Elder  | Elder Jeffrey Holland | Jeffrey | Holland | Elder  |
      | titles          | Deacon | Deacon John Smith     | John    | Smith   | Deacon |
      | titles          | Pastor | Pastor Rick Warren    | Rick    | Warren  | Pastor |
      | titles          | Gen    | Gen George Patton     | George  | Patton  | Gen    |
      | titles          | Maj    | Maj John Smith        | John    | Smith   | Maj    |
      | titles          | Col    | Col John Smith        | John    | Smith   | Col    |
      | titles          | Major  | Major John Smith      | John    | Smith   | Major  |
      | trailing titles | MBA    | Jane Doe, MBA         | Jane    | Doe     | MBA    |
