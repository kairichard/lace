Feature: Listing installed and active pkgs
  As a user i want to see what pkgs are installed
  or active so i can quickly see what commands or aliases might
  be available, or i simply forgot what the name of the pkg was i installed.
  So i can look the name up and use that in subsequent command.

  Scenario: With no installed pkgs
    When I successfully run `lace ls`
    Then the output should contain "There are no pkgs installed"

  Scenario: With one installed pkg
    Given an installed pkg named "mypkg"
    When I successfully run `lace ls`
    Then the output should contain:
    """
    [ ] mypkg
    """

  Scenario: With more than one installed pkg
    Given an installed pkg named "mypkg_1"
    Given an installed pkg named "mypkg_2"
    Given an installed pkg named "mypkg_3"
    When I successfully run `lace ls`
    Then the output should contain:
    """
    [ ] mypkg_1
    [ ] mypkg_2
    [ ] mypkg_3
    """
  Scenario: Active Kits are marked with a star
    Given an active pkg named "mypkg"
    Given an installed pkg named "otherpkg"
    When I successfully run `lace ls`
    Then the output should contain:
    """
    [*] mypkg
    [ ] otherpkg
    """

  Scenario: Active Kits are marked with a star also when they have flavors
    Given an active pkg with flavors named "mypkg"
    When I successfully run `lace ls`
    Then the output should contain:
    """
    [*] mypkg
    """

