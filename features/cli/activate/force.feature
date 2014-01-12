Feature: Forcing a activation
  As a user I want to activate a package
  which may override already existing files

  Scenario: Trying to deactivate an incomplete package
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    config_files:
      - bashrc
      - vimrc
    """
    And a file named "cassia/simple/bashrc" with:
    """
    pkg
    """
    And a file named "HOME/.bashrc" with:
    """
    default
    """
    And an empty file named "cassia/simple/vimrc"
    When I run `lace install cassia/simple`
    Then the output should contain:
    """
    Error: File exists
    """
    When I run `lace activate simple --force`
    And the following files should exist:
      | HOME/.bashrc |
      | HOME/.vimrc |

    And the file "HOME/.bashrc" should contain:
    """
    pkg
    """
