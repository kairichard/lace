Feature: Deactivating with a an empty folder
  https://github.com/kairichard/lace/issues/1

  Scenario: Trying to deactivate with an empty linked folder
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    config_files:
      - empty
    """
    And a directory named "cassia/simple/empty"
    When I successfully run `lace fetch cassia/simple`
    When I run `lace setup simple`
    When I run `lace activate simple`
    Then the following directories should exist:
      | HOME/.empty |
    When I run `lace deactivate simple`
    Then the following directories should not exist:
      | HOME/.empty |
