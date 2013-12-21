Feature: Activating
  As a user i want to activate a kit which is already
  installed so i can use the provided config files.

  Background:
    Given a directory named "cassia/simple"
    And an empty file named "cassia/simple/bashrc"
    And a file named "cassia/simple/dotty.yml" with:
    """
    ---
    config_files:
      - bashrc
    """


  Scenario: Activating by name
    When I run `dotkoon fetch cassia/simple`
    When I run `dotkoon activate simple`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [*] simple
    """
    And the following files should exist:
      | HOME/.bashrc |

  Scenario: Activating by a overridden name
    When I run `dotkoon fetch cassia/simple --name=mykit`
    When I run `dotkoon activate mykit`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [*] mykit
    """
    And the following files should exist:
      | HOME/.bashrc |

  Scenario: Activating one from a list of two
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



