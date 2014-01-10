Feature: Deactivating with flavors
  Some advanced installables may come with flavors
  when they do, the deactivate command needs to know about
  them in order to correctly function

  Background:
    Given a package named "cassia/flavors" with the following manifest:
    """
    ---
    flavors:
      desktop:
        config_files:
          - bashrc
          - defaults
      console:
        config_files:
          - bashrc
          - vimrc

    """
    And an empty file named "cassia/flavors/bashrc"
    And an empty file named "cassia/flavors/defaults"
    And an empty file named "cassia/flavors/vimrc"
    And I run `lace fetch cassia/flavors`
    Then the output should contain "==> Fetching"
    When I successfully run `lace activate flavors desktop`
    And I run `lace ls`
    Then the output should contain:
    """
    - [*] flavors
    """
    And the following files should exist:
      | HOME/.defaults |
      | HOME/.bashrc |

  Scenario: Activating without a flavor fails
    When I run `lace deactivate flavors`
    Then the exit status should be 1
    And the output should contain:
    """
    Sorry, this command needs a flavor argument you can choose from the following:
    - desktop
    - console
    """
    And the folder "HOME/" should be empty

  Scenario: Deactivating with a flavor
    When I run `lace deactivate flavors desktop`
    And I run `lace ls`
    Then the output should contain:
    """
    - [ ] flavors
    """
    And the folder "HOME/" should be empty

  Scenario: Deactivating a flavor which wasnt activated
    When I run `lace deactivate flavors console`
    Then the exit status should be 1
    Then the output should contain:
    """
    Cannot deactivate package that is not active
    """
    And I run `lace ls`
    Then the output should contain:
    """
    - [*] flavors
    """
    And the following files should exist:
      | HOME/.bashrc |
      | HOME/.defaults |

  Scenario: Deactivating more than once raises error
    When I run `lace deactivate flavors desktop`
    Then I run `lace deactivate flavors desktop`
    Then the exit status should be 1
    Then the output should contain:
    """
    Cannot deactivate package that is not active
    """
    And the following files should not exist:
      | HOME/.bashrc |
      | HOME/.defaults |

  Scenario: Deactivating twice with different flavors from the same pkg raises error
    When I run `lace deactivate flavors desktop`
    Then I run `lace deactivate flavors console`
    Then the exit status should be 1
    Then the output should contain:
    """
    Cannot deactivate package that is not active
    """
    And the folder "HOME/" should be empty
