Feature: Installing
  As a user i want to install a pkg from a local or
  remote location so that i can start right away using
  my newly configured system

  Background:
    Given a directory named "cassia/simple"
    And an empty file named "cassia/simple/bashrc"
    And a file named "cassia/simple/.lace.yml" with:
    """
    ---
    config_files:
      - bashrc
    """


  Scenario: Installing from a local dirctory
    When I run `lace install cassia/simple`
    And I run `lace ls`
    Then the output should contain:
    """
    - [*] simple
    """
    And the following files should exist:
      | HOME/.bashrc |

  Scenario: Installing from a local dirctory twice
    When I run `lace install cassia/simple`
    And I run `lace install cassia/simple`
    Then the output should contain:
    """
    Package already installed
    """
    And the following files should exist:
      | HOME/.bashrc |

  Scenario: Installing from a local dirctory with a name
    When I run `lace install cassia/simple --name=mypkg`
    And I run `lace ls`
    Then the output should contain:
    """
    - [*] mypkg
    """
    And the following files should exist:
      | HOME/.bashrc |

  Scenario: Installing from a local dirctory with a name
    When I run `lace install cassia/simple --name=mypkg`
    And I run `lace ls`
    Then the output should contain:
    """
    - [*] mypkg
    """
    And the following files should exist:
      | HOME/.bashrc |
