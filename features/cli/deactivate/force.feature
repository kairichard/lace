Feature: Forcing a deactivation
  As a user I want to deactivate a package which is even if not all
  files from the package can be found in HOME

  Scenario: Trying to deactivate an incomplete package
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    config_files:
      - bashrc
      - vimrc
      - ackrc
      - gitignore
    """
    And an empty file named "cassia/simple/bashrc"
    And an empty file named "cassia/simple/vimrc"
    And an empty file named "cassia/simple/ackrc"
    And an empty file named "cassia/simple/gitignore"
    When I successfully run `lace fetch cassia/simple`
    When I successfully run `lace install simple`
    And the following files should exist:
      | HOME/.bashrc |
      | HOME/.vimrc |
      | HOME/.ackrc |
      | HOME/.gitignore |
    Then I remove the file "HOME/.vimrc"
    Then I run `lace deactivate simple`
    Then the output should contain:
    """
    Cannot deactivate package that is not active
    """
    Then I run `lace deactivate simple --force`
    And the following files should not exist:
      | HOME/.bashrc |
      | HOME/.vimrc |
      | HOME/.ackrc |
      | HOME/.gitignore |

