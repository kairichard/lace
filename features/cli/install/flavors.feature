Feature: Installing with flavors from a location
  Some advanced installables may come with flavors
  which gives the user a finer grained control over where to install what

  Background:
    Given a directory named "cassia/flavors"
    And an empty file named "cassia/flavors/bashrc"
    And an empty file named "cassia/flavors/vimrc"
    And a file named "cassia/flavors/.zimt.yml" with:
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

  Scenario: Installing with a flavor
    When I run `dotkoon install cassia/flavors desktop`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [*] flavors
    """
    And the following files should exist:
      | HOME/.bashrc |

  Scenario: Installing with another flavor
    When I run `dotkoon install cassia/flavors console`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [*] flavors
    """
    And the following files should exist:
      | HOME/.bashrc |
      | HOME/.vimrc |


  Scenario: Installing with a flavor and a custome name
    When I run `dotkoon install cassia/flavors desktop --name=mykit`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [*] mykit
    """
    And the following files should exist:
      | HOME/.bashrc |


