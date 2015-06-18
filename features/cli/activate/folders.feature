Feature: Activating with folders as configs
  As a user I want to activate a pkg
  that has overlapping config folders so I can use the
  provided config files.

  Background:
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    config_files:
      - bashrc
      - config
    """
    And an empty file named "cassia/simple/bashrc"
    And an empty file named "cassia/simple/config/bar"
    And a file named "cassia/simple/config/foo" with:
    """
    Something somthing
    """

  Scenario: I activate
    When I run `lace fetch cassia/simple`
    When I run `lace activate simple`
    And the following files should exist:
      | HOME/.bashrc        |
      | HOME/.config/foo    |
      | HOME/.config/bar    |

  Scenario: I activate with same folder in HOME using force
    Given an empty file named "HOME/.config/screen"
    When I run `lace fetch cassia/simple`
    When I run `lace activate simple -f`
    And the following files should exist:
      | HOME/.bashrc            |
      | HOME/.config/foo        |
      | HOME/.config/bar        |
      | HOME/.config.bak/screen |
    And the following files should not exist:
      | HOME/.config/screen     |

  Scenario: I activate with same folder in HOME using force override existing file
    Given an empty file named "HOME/.config/foo"
    When I run `lace fetch cassia/simple`
    When I run `lace activate simple -f`
    And the following files should exist:
      | HOME/.bashrc        |
      | HOME/.config/foo    |
      | HOME/.config/bar    |
    And the file "HOME/.config/foo" should contain:
    """
    Something somthing
    """

  Scenario: I activate with same folder in HOME merging folders
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    config_files:
      - bashrc
      - config/*
    """
    Given an empty file named "HOME/.config/screen"
    When I run `lace fetch cassia/simple`
    When I run `lace activate simple`
    And the following files should exist:
      | HOME/.bashrc        |
      | HOME/.config/screen |
      | HOME/.config/foo    |
      | HOME/.config/bar    |

  Scenario: I activate with same folder in HOME merging folders with subfolders
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    config_files:
      - bashrc
      - config/*
    """
    And an empty file named "cassia/simple/config/screen/bar"
    And an empty file named "HOME/.config/screen/"
    And an empty file named "HOME/.config/screen/"
    And an empty file named "HOME/.config/screen/foo"
    When I run `lace fetch cassia/simple`
    When I run `lace activate simple`
    And the following files should exist:
      | HOME/.bashrc            |
      | HOME/.config/screen/foo |
      | HOME/.config/screen/bar |
      | HOME/.config/foo        |
      | HOME/.config/bar        |

