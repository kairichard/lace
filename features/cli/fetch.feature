Feature: Fetching a pkg from a location
  As a user i want to fetch a pkg from a local or
  remote location so that i can interact with it

  Background:
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    config_files:
      - bashrc
    """
    And an empty file named "cassia/simple/bashrc"

  Scenario: Fetching from a local dirctory
    When I run `lace fetch cassia/simple`
    And I run `lace ls`
    Then the output should contain:
    """
    [ ] simple
    """
    And the following files should not exist:
      | HOME/.bashrc |

  Scenario: Fetching from a local dirctory with a name
    When I run `lace fetch cassia/simple --name=mypkg`
    And I run `lace ls`
    Then the output should contain:
    """
    [ ] mypkg
    """
    And the following files should not exist:
      | HOME/.bashrc |

  Scenario: Fetching from a local dirctory without a .lace.yml
    Given a directory named "cassia/nopkg"
    And an empty file named "cassia/nopkg/bashrc"
    When I run `lace fetch cassia/nopkg`
    Then the output should contain:
    """
    Error: Removing fetched files
    """
    And the output should contain "No PackageFacts found in"
    When I run `lace ls`
    Then the output should contain:
    """
    There are no pkgs installed
    """

