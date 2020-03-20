Feature: Listing installed and active pkgs
    As a user i want to see where pkgs are installed as they are the repositories I also change the source in.

    Scenario: With no installed pkgs
        When I run `lace where mypkg`
        And the exit status should be 1
        Then the output should contain:
            """
            Error: Package mypkg is not installed
            """

    Scenario: With one installed pkg
        Given an installed pkg named "mypkg"
        When I successfully run `lace where mypkg`
        Then the output should contain:
            """
            tmp/aruba/installed_cassias/mypkg
            """

    Scenario: With more than one installed pkg
        Given an installed pkg named "mypkg_1"
        Given an installed pkg named "mypkg_2"
        Given an installed pkg named "mypkg_3"
        When I successfully run `lace where mypkg_3`
        Then the output should contain:
            """
            tmp/aruba/installed_cassias/mypkg_3
            """