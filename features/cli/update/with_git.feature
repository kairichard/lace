Feature: Updating a installed pkg which was installed using git
  As a user when I update my own dotfiles
  or a maintainer updates the pkg i installed
  I then want to be able to update that pkg.

  Background:
    Given a git repo in a directory named "cassia/simple_git"
    And an empty file named "cassia/simple_git/bashrc"
    And a file named "cassia/simple_git/.lace.yml" with:
    """
    ---
    config_files:
      - bashrc
    """
    Then I git-commit "cassia/simple_git" saying "Initial"
    And I run `lace install cassia/simple_git`
    Then the following files should exist:
      | HOME/.bashrc |

  Scenario: Updating a pkg which was installed using git
    Given an empty file named "cassia/simple_git/vimrc"
    And a file named "cassia/simple_git/.lace.yml" with:
    """
    ---
    config_files:
      - bashrc
      - vimrc
    """
    Then I git-commit "cassia/simple_git" saying "Adding vimrc"
    Then I run `lace update simple_git`
    Then the following files should exist:
      | HOME/.bashrc |
      | HOME/.vimrc |

  Scenario: Updating a pkg which was installed using git - adding hooks
    Given a file named "cassia/simple_git/hooks/post_update.sh" with mode "775" and with:
    """
    echo "HELLO FROM POST UPDATE HOOK"
    """
    And a file named "cassia/simple_git/.lace.yml" with:
    """
    ---
    config_files:
      - bashrc
      - hooks
    post:
      update:
        - ~/.hooks/post_update.sh
    """
    Then I git-commit "cassia/simple_git" saying "Adding post update hook"
    Then I run `lace update simple_git`
    And the output should contain "HELLO FROM POST UPDATE HOOK"
    And the following files should exist:
      | HOME/.bashrc |
      | HOME/.hooks/post_update.sh |

  Scenario: Updating a pkg which was installed using git - adding hooks but running with no-hooks
    Given a file named "cassia/simple_git/hooks/post_update.sh" with mode "775" and with:
    """
    echo "HELLO FROM POST UPDATE HOOK"
    """
    And a file named "cassia/simple_git/.lace.yml" with:
    """
    ---
    config_files:
      - bashrc
      - hooks
    post:
      update:
        - ~/.hooks/post_update.sh
    """
    Then I git-commit "cassia/simple_git" saying "Adding post update hook"
    Then I run `lace update simple_git --no-hooks`
    And the output should not contain "HELLO FROM POST UPDATE HOOK"
    And the following files should exist:
      | HOME/.bashrc |
      | HOME/.hooks/post_update.sh |
