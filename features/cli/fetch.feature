Feature: Fetching a kit from a location
  As a user i want to fetch a kit from a local or
  remote location so that i can interact with it

  Scenario: Fetching from a local dirctory
    When I run `dotkoon fetch ../../fixtures/kits/simple`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [ ] simple
    """
    And the following files should not exist:
      | HOME/.bashrc |

  Scenario: Fetching from a local dirctory with a name
    When I run `dotkoon fetch ../../fixtures/kits/simple --name=mykit`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [ ] mykit
    """
    And the following files should not exist:
      | HOME/.bashrc |

