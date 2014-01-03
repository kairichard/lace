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
    When I run `dotkoon fetch cassia/simple`
    Then the output should contain "==> Fetching"
    Then I run `dotkoon activate simple`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [*] simple
    """


  Scenario: Deactivating by name
    When I run `dotkoon deactivate simple`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [ ] simple
    """
    And the following files should not exist:
      | HOME/.bashrc |

  Scenario: Deativating one from a list of two
    Given I successfully run `dotkoon deactivate simple`
    And I successfully run `dotkoon remove simple`
    When I run `dotkoon fetch cassia/simple --name=mykit`
    When I run `dotkoon fetch cassia/simple --name=otherkit`
    When I run `dotkoon activate mykit`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [*] mykit
    - [ ] otherkit
    """
    And the following files should exist:
      | HOME/.bashrc |
    Then I run `dotkoon deactivate mykit`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [ ] mykit
    - [ ] otherkit
    """
    And the following files should not exist:
      | HOME/.bashrc |
