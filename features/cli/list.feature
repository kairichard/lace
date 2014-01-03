Feature: Listing installed and active kits
  As a user i want to see what kits are installed
  or active so i can quickly see what commands or aliasses might
  be available, or i simply forgot what the name of the kit was i installed.
  So i can look the name up and use that in subsequent command.

  Scenario: With no installed kits
    When I successfully run `zimt ls`
    Then the output should contain "There are no kits installed"

  Scenario: With one installed kit
    Given an installed kit named "mykit"
    When I successfully run `zimt ls`
    Then the output should contain:
    """
    - [ ] mykit
    """

  Scenario: With more than one installed kit
    Given an installed kit named "mykit_1"
    Given an installed kit named "mykit_2"
    Given an installed kit named "mykit_3"
    When I successfully run `zimt ls`
    Then the output should contain:
    """
    - [ ] mykit_1
    - [ ] mykit_2
    - [ ] mykit_3
    """
  Scenario: Active Kits are marked with a star
    Given an active kit named "mykit"
    Given an installed kit named "otherkit"
    When I successfully run `zimt ls`
    Then the output should contain:
    """
    - [*] mykit
    - [ ] otherkit
    """

  Scenario: Active Kits are marked with a star also when they have flavors
    Given an active kit with flavors named "mykit"
    When I successfully run `zimt ls`
    Then the output should contain:
    """
    - [*] mykit
    """

