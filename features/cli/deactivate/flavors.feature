Feature: Deactivating with flavors
  Some advanced installables may come with flavors
  when they do, the deactivate command needs to know about
  them in order to correctly function

  Background:
    Given a directory named "cassia/flavors"
    And an empty file named "cassia/flavors/bashrc"
    And an empty file named "cassia/flavors/defaults"
    And an empty file named "cassia/flavors/vimrc"
    And a file named "cassia/flavors/dotty.yml" with:
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
    And I run `dotkoon fetch cassia/flavors`
    Then the output should contain "==> Fetching"
    When I successfully run `dotkoon activate flavors desktop`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [*] flavors
    """
    And the following files should exist:
      | HOME/.defaults |
      | HOME/.bashrc |

  Scenario: Activating without a flavor fails
    When I run `dotkoon deactivate flavors`
    Then the exit status should be 1
    And the output should contain:
    """
    Sorry, this command needs a flavor argument you can choose from the following:
    - desktop
    - console
    """
    And the folder "HOME/" should be empty

  Scenario: Deactivating with a flavor
    When I run `dotkoon deactivate flavors desktop`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [ ] flavors
    """
    And the folder "HOME/" should be empty

  Scenario: Deactivating a flavor which wasnt activated
    When I run `dotkoon deactivate flavors console`
    Then the exit status should be 1
    Then the output should contain:
    """
    It looks like the flavor you tried to deactivate is not active after all
    """
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [*] flavors
    """
    And the following files should exist:
      | HOME/.bashrc |
      | HOME/.defaults |

  Scenario: Deactivating more than once raises error
    When I run `dotkoon deactivate flavors desktop`
    Then I run `dotkoon deactivate flavors desktop`
    Then the exit status should be 1
    Then the output should contain:
    """
    It looks like the flavor you tried to deactivate is not active after all
    """
    And the following files should not exist:
      | HOME/.bashrc |
      | HOME/.defaults |

  Scenario: Deactivating twice with different flavors from the same kit raises error
    When I run `dotkoon deactivate flavors desktop`
    Then I run `dotkoon deactivate flavors console`
    Then the exit status should be 1
    Then the output should contain:
    """
    It looks like the flavor you tried to deactivate is not active after all
    """
    And the folder "HOME/" should be empty