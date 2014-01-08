Feature: Updating a installed pkg
  As a user when I update my own dotfiles
  or a maintainer updates the pkg i installed
  I then want to be able to update that pkg.

  Background:
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    config_files:
      - bashrc
    """
    And an empty file named "cassia/simple/bashrc"

  Scenario: Updating a pkg which was installed from a directory
    Given I run `lace install cassia/simple`
    Then I run `lace update simple`
    Then the output should contain:
    """
    Only pkgs installed via git can be updated
    """
    And the exit status should be 1
