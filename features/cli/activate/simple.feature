Feature: Activating
  As a user i want to activate a pkg which is already
  installed so i can use the provided config files.

  Background:
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    config_files:
      - bashrc
    """
    And an empty file named "cassia/simple/bashrc"


  Scenario: Activating by name
    When I run `lace fetch cassia/simple`
    When I run `lace activate simple`
    And I run `lace ls`
    Then the output should contain:
    """
    [*] simple
    """
    And the following files should exist:
      | HOME/.bashrc |

  Scenario: Activating by a overridden name
    When I run `lace fetch cassia/simple --name=mypkg`
    When I run `lace activate mypkg`
    And I run `lace ls`
    Then the output should contain:
    """
    [*] mypkg
    """
    And the following files should exist:
      | HOME/.bashrc |

  Scenario: Activating one from a list of two
    When I run `lace fetch cassia/simple --name=mypkg`
    When I run `lace fetch cassia/simple --name=otherpkg`
    When I run `lace activate mypkg`
    And I run `lace ls`
    Then the output should contain:
    """
    [*] mypkg
    [ ] otherpkg
    """
    And the following files should exist:
      | HOME/.bashrc |



