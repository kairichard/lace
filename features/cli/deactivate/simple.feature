Feature: Deactivating
  As a user i want to deactivate a package which is already
  installed so i can use another one or temporarly disable it.

  Background:
    Given a directory named "cassia/simple"
    And an empty file named "cassia/simple/bashrc"
    And a file named "cassia/simple/.lace.yml" with:
    """
    ---
    config_files:
      - bashrc
    """
    When I run `lace fetch cassia/simple`
    Then the output should contain "==> Fetching"
    Then I run `lace activate simple`
    And I run `lace ls`
    Then the output should contain:
    """
    - [*] simple
    """


  Scenario: Deactivating by name
    When I run `lace deactivate simple`
    And I run `lace ls`
    Then the output should contain:
    """
    - [ ] simple
    """
    And the following files should not exist:
      | HOME/.bashrc |

  Scenario: Deativating one from a list of two
    Given I successfully run `lace deactivate simple`
    And I successfully run `lace remove simple`
    When I run `lace fetch cassia/simple --name=mypkg`
    When I run `lace fetch cassia/simple --name=otherpkg`
    When I run `lace activate mypkg`
    And I run `lace ls`
    Then the output should contain:
    """
    - [*] mypkg
    - [ ] otherpkg
    """
    And the following files should exist:
      | HOME/.bashrc |
    Then I run `lace deactivate mypkg`
    And I run `lace ls`
    Then the output should contain:
    """
    - [ ] mypkg
    - [ ] otherpkg
    """
    And the following files should not exist:
      | HOME/.bashrc |
