Feature: Installing with flavors from a location
  Some advanced installables may come with flavors
  which gives the user a finer grained control over where to install what

  Background:
    Given a package named "cassia/flavors" with the following manifest:
    """
    ---
    flavors:
      desktop:
        config_files:
          - bashrc
      console:
        config_files:
          - bashrc
          - vimrc

    """
    And an empty file named "cassia/flavors/bashrc"
    And an empty file named "cassia/flavors/vimrc"

  Scenario: Installing with a flavor
    When I run `lace install cassia/flavors desktop`
    And I run `lace ls`
    Then the output should contain:
    """
    - [*] flavors
    """
    And the following files should exist:
      | HOME/.bashrc |

  Scenario: Installing with another flavor
    When I run `lace install cassia/flavors console`
    And I run `lace ls`
    Then the output should contain:
    """
    - [*] flavors
    """
    And the following files should exist:
      | HOME/.bashrc |
      | HOME/.vimrc |


  Scenario: Installing with a flavor and a custome name
    When I run `lace install cassia/flavors desktop --name=mypkg`
    And I run `lace ls`
    Then the output should contain:
    """
    - [*] mypkg
    """
    And the following files should exist:
      | HOME/.bashrc |

  Scenario: Installing a package with the wrong flavor
    When I run `lace install cassia/flavors wrong_flavor`
    Then the output should contain:
    """
    Error: Flavor 'wrong_flavor' does not exist
    Error: Package remains installed but was not activated
    """
    And I run `lace ls`
    And the output should contain:
    """
    - [ ] flavors
    """

  Scenario: Installing a package with the wrong flavor
    When I run `lace install cassia/flavors`
    Then the output should contain:
    """
    Error: Sorry, this command needs a flavor argument you can choose from the following:
    - desktop
    - console
    Error: Package remains installed but was not activated
    """
    And I run `lace ls`
    And the output should contain:
    """
    - [ ] flavors
    """


