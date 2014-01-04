Feature: Installing with flavors from a location
  Some advanced installables may come with flavors
  which gives the user a finer grained control over where to install what

  Background:
    Given a directory named "cassia/flavors"
    And an empty file named "cassia/flavors/bashrc"
    And an empty file named "cassia/flavors/vimrc"
    And a file named "cassia/flavors/.lace.yml" with:
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


