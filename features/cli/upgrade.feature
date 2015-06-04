Feature: Upgrade a current lace installation
  As a user i want to update lace without doing much work
  So lace should provide a way to upgrade the current installation
  very smoothly


 Scenario: Upgrading deactivates and activates again
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    config_files:
      - bashrc
    """
    And an empty file named "cassia/simple/bashrc"
    When I run `lace fetch cassia/simple --name=mypkg`
    Then I run `lace activate mypkg`
    And I run `lace ls`
    Then the output should contain:
    """
    [*] mypkg
    """

    And I run `lace --upgrade`
    Then the output should contain:
    """
    Please deactivate all packages before continuing
    """

  Scenario: Upgrading from 0.x.x to a version where the LACE_FOLDER get renamed
    Given an empty file named "HOME/.cassias/pkg/test"
    And I run `lace --upgrade`

    And the following files should not exist:
      | HOME/.cassias/pkg/test |

    Then the following files should exist:
      | installed_cassias/pkg/test |


