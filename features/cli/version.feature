Feature: Expose the current version to the user
  As a user
  I want to be able to check the blimpy version
  So that I can tell if I should update or not

  Scenario: Simple version check
    When I run `blimpy version`
    Then the output should contain the current Blimpy version
