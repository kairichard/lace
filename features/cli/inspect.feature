@wip
Feature: Getting information about a installed pkg
  As a user i want to be able to inspect a pkg and see
  which flavors it brings and where the hooks are stored
  also i want to see whether its active or not if a version is
  provided that show that too. And i want to see the location of
  the manifest file so i can look at it myself. Also show if its upgrade
  able.

  Scenario: Inspecting a simple pkg
    Given a directory named "cassia/simple"
    And an empty file named "cassia/simple/bashrc"
    And a file named "cassia/simple/dotty.yml" with:
    """
    ---
    config_files:
      - bashrc
    """
    Then I run `dotkoon fetch cassia/simple`
    And I run `dotkoon inspect simple`
    Then the output should contain:
    """
    Inspection of simple:
      active:      false
      flavors:     none
      version:     n/a
      upgradeable: false
      manifest:    HOME/installed_cassias/simple/dotty.yml
    """


