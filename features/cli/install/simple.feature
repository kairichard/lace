Feature: Installing
  As a user i want to install a kit from a local or
  remote location so that i can start right away using
  my newly configured system

  Background:
    Given a directory named "cassia/simple"
    And an empty file named "cassia/simple/bashrc"
    And a file named "cassia/simple/dotty.yml" with:
    """
    ---
    config_files:
      - bashrc
    """


  Scenario: Installing from a local dirctory
    When I run `dotkoon install cassia/simple`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [*] simple
    """
    And the following files should exist:
      | HOME/.bashrc |

  Scenario: Installing from a local dirctory twice
    When I run `dotkoon install cassia/simple`
    And I run `dotkoon install cassia/simple`
    Then the output should contain:
    """
    Package already installed
    """
    And the following files should exist:
      | HOME/.bashrc |

  Scenario: Installing from a local dirctory with a name
    When I run `dotkoon install cassia/simple --name=mykit`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [*] mykit
    """
    And the following files should exist:
      | HOME/.bashrc |

  Scenario: Installing from a local dirctory with a name
    When I run `dotkoon install cassia/simple --name=mykit`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [*] mykit
    """
    And the following files should exist:
      | HOME/.bashrc |
