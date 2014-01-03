Feature: Deactivating
  As a user i want to deactivate a package which is already
  installed so i can use another one or temporarly disable it.

  Background:
    Given a directory named "cassia/simple"
    And an empty file named "cassia/simple/bashrc"
    And a file named "cassia/simple/.zimt.yml" with:
    """
    ---
    config_files:
      - bashrc
    """
    When I run `zimt fetch cassia/simple`
    Then the output should contain "==> Fetching"
    Then I run `zimt activate simple`
    And I run `zimt ls`
    Then the output should contain:
    """
    - [*] simple
    """


  Scenario: Deactivating by name
    When I run `zimt deactivate simple`
    And I run `zimt ls`
    Then the output should contain:
    """
    - [ ] simple
    """
    And the following files should not exist:
      | HOME/.bashrc |

  Scenario: Deativating one from a list of two
    Given I successfully run `zimt deactivate simple`
    And I successfully run `zimt remove simple`
    When I run `zimt fetch cassia/simple --name=mykit`
    When I run `zimt fetch cassia/simple --name=otherkit`
    When I run `zimt activate mykit`
    And I run `zimt ls`
    Then the output should contain:
    """
    - [*] mykit
    - [ ] otherkit
    """
    And the following files should exist:
      | HOME/.bashrc |
    Then I run `zimt deactivate mykit`
    And I run `zimt ls`
    Then the output should contain:
    """
    - [ ] mykit
    - [ ] otherkit
    """
    And the following files should not exist:
      | HOME/.bashrc |
