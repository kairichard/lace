Feature: Updating a installed kit
  As a user when I update my own dotfiles
  or a maintainer updates the kit i installed
  I then want to be able to update that kit.

  Background:
    Given a directory named "cassia/simple"
    And an empty file named "cassia/simple/bashrc"
    And a file named "cassia/simple/.zimt.yml" with:
    """
    ---
    config_files:
      - bashrc
    """

  Scenario: Updating a kit which was installed from a directory
    Given I run `dotkoon install cassia/simple`
    Then I run `dotkoon update simple`
    Then the output should contain:
    """
    Only kits installed via git can be updated
    """
    And the exit status should be 1
