@wip @announce
Feature: Deactivating with folders as configs
  As a user I want to deactivate a pkg
  that has overlapping config folders so I can
  safely deactivate a given package and get my old config back

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

  Scenario: I activate with same folder in HOME merging folders with subfolders
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    config_files:
      - bashrc
      - config/**/*
    """
    And an empty file named "cassia/simple/config/screen/bar"
    And an empty file named "cassia/simple/config/something/subfolder/asd"
    And an empty file named "HOME/.config/screen/foo"
    And an empty file named "HOME/.config/something/foo"
    When I run `lace fetch cassia/simple`
    When I run `lace activate simple`
    When I successfully run `lace deactivate simple`
    And the following files should exist:
      | HOME/.config/screen/foo              |
      | HOME/.config/something/foo           |
    And the following files should not exist:
      | HOME/.config/something/subfolder/asd |
      | HOME/.config/screen/bar              |
      | HOME/.config/foo                     |
      | HOME/.config/bar                     |
