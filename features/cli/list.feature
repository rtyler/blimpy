Feature: List running VMs

  Scenario: With no running VMs
    Given I have the Blimpfile:
      """
      # Empty!
      """
    When I run `blimpy list`
    Then the exit status should be 0
    And the output should contain:
      """
      No currently running VMs
      """
