@wip
Feature: Validation of a manifest file
  As a User I want to publish my dotfiles in a way that
  other zimt user can use them. In order to supply a correct manifest
  and thus installable pkg there is a command which tests a manifest for
  errors and reports them.

  Scenario: Validation Report Header
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    """
    Then I run `dotkoon validate cassia/simple`
    Then the exit status should be 1
    And the output should contain:
    """
    Zimt-Manifest Validation Report:
    """

  Scenario: A manifest with config_files part
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    config_files:
      - bashrc
    """
    And an empty file named "cassia/simple/bashrc"
    Then I run `dotkoon validate cassia/simple`
    Then the exit status should be 1
    And the output should contain:
    """
      config-files:                                              [ found ]
    """

  Scenario: A manifest with config_files where a files is missing
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    config_files:
      - bashrc
      - not_there
    """
    And an empty file named "cassia/simple/bashrc"
    And a file named "cassia/simple/not_there" should not exist
    Then I run `dotkoon validate cassia/simple`
    Then the exit status should be 1
    And the output should contain:
    """
      config-files:                                              [ error ]
        # not_there is missing from this package
    """

  Scenario: A manifest without config_files part
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    config_files_with_a_typo:
      - bashrc
    """
    Then I run `dotkoon validate cassia/simple`
    Then the exit status should be 1
    And the output should contain:
    """
      config-files:                                              [ missing ]
        # Add config_files see manual for more information
    """

  Scenario: A manifest with version part
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    version: 1.0
    """
    Then I run `dotkoon validate cassia/simple`
    Then the exit status should be 1
    And the output should contain:
    """
      version:                                                   [ found ]
    """

  Scenario: A manifest without version part
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    no_version: 1.0
    """
    Then I run `dotkoon validate cassia/simple`
    Then the exit status should be 1
    And the output should contain:
    """
      version:                                                   [ missing ]
        # adding a version to the manifest improves
        # a future update experince
    """

  Scenario: A manifest with homepage part
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    homepage: http://example.org
    """
    Then I run `dotkoon validate cassia/simple`
    Then the exit status should be 1
    And the output should contain:
    """
      homepage:                                                  [ found ]
    """

  Scenario: A manifest without homepage part
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    no_homepage: nil
    """
    Then I run `dotkoon validate cassia/simple`
    Then the exit status should be 1
    And the output should contain:
    """
      homepage:                                                  [ missing ]
        # adding a homepage improves credebility
        # of your package
    """

  Scenario: A manifest with no hooks
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    """
    Then I run `dotkoon validate cassia/simple`
    Then the exit status should be 1
    And the output should contain:
    """
      post-install hook:                                         [ skipped ]
    """

  Scenario: A manifest where a post install hook cannot be found
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    post:
      install:
        - ~/.hooks/post_install.sh
        - ~/.hooks/another_hook.sh
    """
    Then I run `dotkoon validate cassia/simple`
    Then the exit status should be 1
    And the output should contain:
    """
      post-install hook:                                         [ error ]
        # ~/.hooks/post_install.sh cannot be found
        # ~/.hooks/another_hook.sh cannot be found
        """

  Scenario: A manifest where a post install hook is not executable
    Given an empty file named "cassia/simple/hooks/post_install.sh"
    And a package named "cassia/simple" with the following manifest:
    """
    ---
    post:
      install:
        - cassia/simple/hooks/post_install.sh
    """
    Then I run `dotkoon validate cassia/simple`
    Then the exit status should be 1
    And the output should contain:
    """
      post-install hook:                                         [ error ]
        # cassia/simple/hooks/post_install.sh is not executable
    """

  Scenario: A manifest where a post install hook cannot be found
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    post:
      update:
        - ~/.hooks/post_update.sh
        - ~/.hooks/another_hook.sh
    """
    Then I run `dotkoon validate cassia/simple`
    Then the exit status should be 1
    And the output should contain:
    """
      post-update hook:                                          [ error ]
        # ~/.hooks/post_update.sh cannot be found
        # ~/.hooks/another_hook.sh cannot be found
        """

  Scenario: A manifest where a post install hook is not executable
    Given an empty file named "cassia/simple/hooks/post_install.sh"
    And a package named "cassia/simple" with the following manifest:
    """
    ---
    post:
      update:
        - cassia/simple/hooks/post_install.sh
    """
    Then I run `dotkoon validate cassia/simple`
    Then the exit status should be 1
    And the output should contain:
    """
      post-update hook:                                          [ error ]
        # cassia/simple/hooks/post_install.sh is not executable
    """

  Scenario: A manifest where everything is ok
    Given an empty file named "cassia/simple/hooks/post_install.sh"
    Given the file named "cassia/simple/hooks/post_install.sh" has mode "755"
    And an empty file named "cassia/simple/bashrc"
    And a package named "cassia/simple" with the following manifest:
    """
    ---
    version: 0.1
    homepage: http://example.org
    config_files:
      - bashrc
    post:
      update:
        - cassia/simple/hooks/post_install.sh
    """
    Then I run `dotkoon validate cassia/simple`
    Then the exit status should be 0
