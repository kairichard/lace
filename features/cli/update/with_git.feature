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
    And I cd to "cassia/simple_git"
    Then I run `git add .`
    Then I run `git commit -am 'Test'`
    Then I cd to "../../"

  Scenario: Updating a kit which was installed from a directory
    Given I run `dotkoon install cassia/simple_git`
    Then the following files should exist:
      | HOME/.bashrc |
    And an empty file named "cassia/simple_git/vimrc"
    And a file named "cassia/simple_git/dotty.yml" with:
    """
    ---
    config_files:
      - bashrc
      - vimrc
    """
    And I cd to "cassia/simple_git"
    Then I run `git add .`
    Then I run `git commit -am 'Adding vimrc'`
    Then I cd to "../../"
    Then I run `dotkoon update simple_git`
    Then the following files should exist:
      | HOME/.bashrc |
      | HOME/.vimrc |
