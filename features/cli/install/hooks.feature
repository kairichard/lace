Feature: Installable comes with a hook
  Some advanced installables may require the host to
  have some software package or some file installed
  In order to achive that one can you hooks defined in the
  manifest.

  Background:
    Given a directory named "cassia/hooks"
    And an empty file named "cassia/hooks/bashrc"
    And an empty file named "cassia/hooks/vimrc"
    And a file named "cassia/hooks/hooks/post_install.sh" with:
    """
    echo "HELLO FROM POST INSTALL HOOK"
    """
    And a file named "cassia/hooks/dotty.yml" with:
    """
    ---
    config_files:
      - bashrc
      - hooks
    post:
      install:
          - ~/.hooks/post_install.sh
    """

  Scenario: Fetching from a local dirctory with a post install hook
    When I run `dotkoon install cassia/hooks`
    And I run `dotkoon ls`
    Then the output should contain "HELLO FROM POST INSTALL HOOK"
    Then the output should contain:
    """
    - [*] hooks
    """
    And the following files should exist:
      | HOME/.bashrc |
      | HOME/.hooks/post_install.sh |

