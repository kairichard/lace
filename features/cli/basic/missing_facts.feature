Feature: Commands should error when there are no PackageFacts
  When I use lace with a director that does not have PackageFacts
  it should throw an error.

  Background:
    Given a directory named "cassia/no_facts"
    And an empty file named "cassia/no_facts/bashrc"

  Scenario Outline: Running a command
    Given I run `lace <cmd> cassia/no_facts`
    Then the exit status should be 1
    And the output should contain "No PackageFacts found in "
    And the output should contain "<output>"

  Examples:
      | cmd      | output |
      | validate | cassia/no_facts |
      | install  | no_facts |
