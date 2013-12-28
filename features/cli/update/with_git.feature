Feature: Updating a installed kit which was installed using git
  As a user when I update my own dotfiles
  or a maintainer updates the kit i installed
  I then want to be able to update that kit.

  Background:
    Given a git repo in a directory named "cassia/simple_git"
    And an empty file named "cassia/simple_git/bashrc"
    And a file named "cassia/simple_git/dotty.yml" with:
    """
    ---
    config_files:
      - bashrc
    """
    Then I git-commit "cassia/simple_git" saying "Initial"
    And I run `dotkoon install cassia/simple_git`
    Then the following files should exist:
      | HOME/.bashrc |

  Scenario: Updating a kit which was installed using git
    Given an empty file named "cassia/simple_git/vimrc"
    And a file named "cassia/simple_git/dotty.yml" with:
    """
    ---
    config_files:
      - bashrc
      - vimrc
    """
    Then I git-commit "cassia/simple_git" saying "Adding vimrc"
    Then I run `dotkoon update simple_git`
    Then the following files should exist:
      | HOME/.bashrc |
      | HOME/.vimrc |
