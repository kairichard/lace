@wip
Feature: Updating a installed pkg which was installed using git when it has flavors
  As a user when I update my own dotfiles
  or a maintainer updates the pkg I installed
  I then want to be able to update that pkg even when it comes with flavors.
  And I want possible new config files to be automatically present in my home.

  Background:
    Given a git repo in a directory named "cassia/flavor_git"
    And an empty file named "cassia/flavor_git/bashrc"
    And an empty file named "cassia/flavor_git/vimrc"
    And a file named "cassia/flavor_git/.lace.yml" with:
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
    Then I git-commit "cassia/flavor_git" saying "Initial"
    And I run `lace fetch cassia/flavor_git`

  Scenario: Updating a pkg which was installed using git adding a file to the active flavor
    Given I run `lace activate flavor_git desktop`
    Then the following files should exist:
      | HOME/.bashrc |
    Then a file named "cassia/flavor_git/.lace.yml" with:
    """
    ---
    flavors:
      desktop:
        config_files:
          - bashrc
          - osx
      console:
        config_files:
          - bashrc
          - vimrc
    """
    And an empty file named "cassia/flavor_git/osx"
    Then I git-commit "cassia/flavor_git" saying "Adding osx to the desktop flavor"
    Then I successfully run `lace update flavor_git desktop`
    Then the following files should exist:
      | HOME/.bashrc |
      | HOME/.osx |


