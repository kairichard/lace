Feature: Invoking commands that come with lace
  The list of available commands is handled by the
  help message, but when there I as a user use a command which
  does not exist then I want a friendly message saying that
  there is no such command


  Scenario: Invoking an unkown command
    Given I run `lace not_here`
    Then the output should not contain "Report this bug"
    And the exit status should be 1
    And the output should contain:
    """
    Error: Unknown command: not_here
    """
