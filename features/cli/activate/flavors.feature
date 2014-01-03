Feature: Activating with flavors
  Some advanced installables may come with flavors
  which gives the user a finer grained control over what he wants
  to activate

  Background:
    Given a directory named "cassia/flavors"
    And an empty file named "cassia/flavors/bashrc"
    And an empty file named "cassia/flavors/vimrc"
    And a file named "cassia/flavors/.zimt.yml" with:
    """
    ---
    flavors:
      desktop:
        config_files:
          - bashrc
      console:
        config_files:
          - bashrc
          - vimrc

    """
    And I run `zimt fetch cassia/flavors`
    Then the output should contain "==> Fetching"
    And I run `zimt ls`
    Then the output should contain:
    """
    - [ ] flavors
    """

  Scenario: Activating without a flavor fails
    When I run `zimt activate flavors`
    Then the exit status should be 1
    And the output should contain:
    """
    Sorry, this command needs a flavor argument you can choose from the following:
    - desktop
    - console
    """
    And the following files should not exist:
      | HOME/.bashrc |

  Scenario: Installing with a flavor
    When I run `zimt activate flavors desktop`
    And I run `zimt ls`
    Then the output should contain:
    """
    - [*] flavors
    """
    And the following files should exist:
      | HOME/.bashrc |

  Scenario: Installing with another flavor
    When I run `zimt activate flavors console`
    And I run `zimt ls`
    Then the output should contain:
    """
    - [*] flavors
    """
    And the following files should exist:
      | HOME/.bashrc |
      | HOME/.vimrc |

  Scenario: Installing more than one flavor from the same kit
    When I run `zimt activate flavors desktop`
    Then I run `zimt activate flavors console`
    Then the exit status should be 1
    Then the output should contain:
    """
    Cannot activate an already active package, please deactivate first
    """
    And the following files should exist:
      | HOME/.bashrc |
    And the following files should not exist:
      | HOME/.vimrc |

