Feature: Installable comes with hooks
  Some advanced installables may require the host to
  have some software package or some file present
  In order to achieve that one can define hooks in the
  manifest.

  Background:
    Given a package named "cassia/hooks" with the following manifest:
      """
      ---
      config_files:
      - bashrc
      - hooks
      setup:
      - ~/.hooks/post_install.sh
      """
    And an empty file named "cassia/hooks/bashrc"
    And an empty file named "cassia/hooks/vimrc"
    And a file named "cassia/hooks/hooks/post_install.sh" with mode "775" and with:
      """
      echo "HELLO FROM POST INSTALL HOOK"
      """

  Scenario: Installing from a local directory with a post install hook
    When I run `lace fetch cassia/hooks`
    And I run `lace setup hooks`
    Then the output should contain "HELLO FROM POST INSTALL HOOK"
    And I run `lace ls`
    Then the output should contain:
      """
      [*] hooks
      """
    And the following files should exist:
      | HOME/.bashrc                |
      | HOME/.hooks/post_install.sh |

  Scenario: Installing with --no-hooks flag
    When I run `lace fetch cassia/hooks`
    When I run `lace setup hooks --no-hooks`
    Then the output should not contain "HELLO FROM POST INSTALL HOOK"

  Scenario: Installing sets environment variables accessible by the hook
    When a file named "cassia/hooks/hooks/post_install.sh" with mode "775" and with:
      """
      echo "ENV: $LACEPKG_PATH"
      """
    When I run `lace fetch cassia/hooks`
    When I run `lace setup hooks`
    Then the output should contain "tmp/aruba/installed_cassias/hooks"

  Scenario: Installing from a local directory with a post install hook that is not executable
    Given the file named "cassia/hooks/hooks/post_install.sh" has mode "655"
    When I run `lace fetch cassia/hooks`
    When I run `lace setup hooks`
    Then the exit status should be 1

  Scenario: Installing from a local directory with a post install hook that is not at the given location
    Given I rename "cassia/hooks/hooks/post_install.sh" to "cassia/hooks/hooks/post_insall_typo.sh"
    When I run `lace fetch cassia/hooks`
    When I run `lace setup hooks`
    Then the exit status should be 1

  Scenario: Installing from a local directory with a post install hook that requires interaction
    When a file named "cassia/hooks/hooks/post_install.sh" with mode "775" and with:
      """
      #!/usr/bin/env python3
      from __future__ import print_function
      import sys
      if __name__ == '__main__':
        result = input("Please answer yes or no: ")
        print(result)
      """
    When I run `lace fetch cassia/hooks`
    When I run `lace setup hooks` interactively
    When I type "TEST"
    Then the output should contain "TEST"

