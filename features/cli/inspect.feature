Feature: Getting information about a installed pkg
  As a user i want to be able to inspect a pkg and see
  which flavors it brings and where the hooks are stored
  also i want to see whether its active or not if a version is
  provided that show that too. And i want to see the location of
  the manifest file so i can look at it myself. Also show if its upgrade
  able.

  Scenario: Inspecting a simple pkg
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    config_files:
      - bashrc
    """
    And an empty file named "cassia/simple/bashrc"
    Then I run `lace fetch cassia/simple`
    And I run `lace inspect simple`
    Then the output should contain:
    """
    Inspection of simple:
      active:      false
      flavors:     nil
      version:     n/a
      upgradeable: false
    """

  Scenario: Inspecting an installed and active pkg
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    version: 1.0.0
    config_files:
      - bashrc
    """
    And an empty file named "cassia/simple/bashrc"
    Then I run `lace install cassia/simple`
    And I run `lace inspect simple`
    Then the output should contain:
    """
    Inspection of simple:
      active:      true
      flavors:     nil
      version:     1.0.0
      upgradeable: false
    """

  Scenario: Inspecting an installed pkg which has flavors
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    version: 1.0.0
    flavors:
      desktop:
        config_files:
          - bashrc
      console:
        config_files:
          - bashrc
          - vimrc

    """
    And an empty file named "cassia/simple/bashrc"
    Then I run `lace fetch cassia/simple`
    And I run `lace inspect simple`
    Then the output should contain:
    """
    Inspection of simple:
      active:      false
      flavors:     desktop, console
      version:     1.0.0
      upgradeable: false
    """

  Scenario: Inspecting an installed pkg which was installed using git
    Given a git-package named "cassia/simple_git" with the following manifest:
    """
    ---
    config_files:
      - bashrc
    """
    And an empty file named "cassia/simple_git/bashrc"
    Then I git-commit "cassia/simple_git" saying "Initial"
    And I run `lace install cassia/simple_git`
    And I run `lace inspect simple_git`
    Then the output should contain:
    """
    Inspection of simple_git:
      active:      true
      flavors:     nil
      version:     n/a
      upgradeable: true
    """


