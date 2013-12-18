Feature: Installing a kit from a location
  As a user i want to install a kit from a local or
  remote location so that i can start right away using
  my newly configured system

  Background:
    Given a directory named "cassia/simple"
    And an empty file named "cassia/simple/bashrc"
    And a file named "cassia/simple/dotty.yml" with:
    """
    ---
    config_files:
      - bashrc
    """


  Scenario: Fetching from a local dirctory
    When I run `dotkoon install cassia/simple`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [*] simple
    """
    And the following files should exist:
      | HOME/.bashrc |

  Scenario: Fetching from a local dirctory with a name
    When I run `dotkoon install cassia/simple --name=mykit`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [*] mykit
    """
    And the following files should exist:
      | HOME/.bashrc |

  Scenario: Fetching from a local dirctory with a red flavor
    When I run `dotkoon install ../../fixtures/kits/with_flavors red`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [*] with_flavors
    """
    And the following files should exist:
      | HOME/.bashrc |

  Scenario: Fetching from a local dirctory with a name and a red flavor
    When I run `dotkoon install ../../fixtures/kits/with_flavors red --name=mykit`
    And I run `dotkoon ls`
    Then the output should contain:
    """
    - [*] mykit
    """
    And the following files should exist:
      | HOME/.bashrc |

  Scenario: Fetching from a local dirctory with a post install hook
    When I run `dotkoon install ../../fixtures/kits/with_post_install_hook`
    And I run `dotkoon ls`
    Then the output should contain "POST INSTALL HOOK FROM SCRIPT"
    Then the output should contain:
    """
    - [*] with_post_install_hook
    """
    And the following files should exist:
      | HOME/.bashrc |
      | HOME/.hooks/post_install.sh |

