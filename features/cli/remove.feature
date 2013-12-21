Feature: Removing a Kit
  As a user i want to be able to remove the physical
  kit from the filesystem so it does not clutter the list
  of available kits anymore.

  Scenario: Removing a single kit:
    Given an installed kit named "mykit"
    When I run `dotkoon rm mykit`
    Then the output should contain "==> Removing"
    Then the output should contain "Successfully removed"
    And I run `dotkoon ls`
    Then the output should contain "There are no kits installed"

  Scenario: Removing an active kit fails:
    Given an active kit named "mykit"
    When I run `dotkoon rm mykit`
    Then the output should contain "Cannot remove active kit, deactivate first"
    Then the exit status should be 1

  Scenario: Removing an single kit with flavors:
    Given an installed kit with flavors named "mykit"
    When I run `dotkoon rm mykit`
    Then the output should contain "==> Removing"
    Then the output should contain "Successfully removed"
    And I run `dotkoon ls`
    Then the output should contain "There are no kits installed"
