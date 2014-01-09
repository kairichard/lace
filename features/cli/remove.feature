Feature: Removing a Kit
  As a user i want to be able to remove the physical
  pkg from the filesystem so it does not clutter the list
  of available pkgs anymore.

  Scenario: Removing a single pkg:
    Given an installed pkg named "mypkg"
    When I run `lace rm mypkg`
    Then the output should contain "==> Removing"
    And I run `lace ls`
    Then the output should contain "There are no pkgs installed"

  Scenario: Removing an active pkg fails:
    Given an active pkg named "mypkg"
    When I run `lace rm mypkg`
    Then the output should contain "Cannot remove active pkg, deactivate first"
    Then the exit status should be 1

  Scenario: Removing an single pkg with flavors:
    Given an installed pkg with flavors named "mypkg"
    When I run `lace rm mypkg`
    Then the output should contain "==> Removing"
    And I run `lace ls`
    Then the output should contain "There are no pkgs installed"
