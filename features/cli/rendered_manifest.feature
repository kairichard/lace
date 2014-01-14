Feature: The .lace.yml it's self is configurable
  As I package auther I want to have some control
  over what the .lace.yml will end up looking.

  Scenario: Making setup path absolute through erb
    Given an empty file named "cassia/simple/hooks/post_install.sh"
    Given the file named "cassia/simple/hooks/post_install.sh" has mode "755"
    And a package named "cassia/simple" with the following manifest:
    """
    ---
    setup:
      - <%= @package_path/"hooks/post_install.sh" %>
    """
    Then I run `lace validate cassia/simple`
    Then the exit status should be 1
    And the output should contain:
    """
      setup:                                                     [ ok ]
    """

  Scenario: .lace.yml with a syntax error
    Given an empty file named "cassia/simple/hooks/post_install.sh"
    Given the file named "cassia/simple/hooks/post_install.sh" has mode "755"
    And a package named "cassia/simple" with the following manifest:
    """
    ---
    setup:
      - <%= not_found %>
    """
    Then I run `lace validate cassia/simple`
    Then the exit status should be 1
    And the output should contain:
    """
    Error: undefined local variable or method `not_found' for #<Facts:cassia/simple>
    in cassia/simple/.lace.yml
    """


