Feature: Show running VMs

  Scenario: With no running VMs
    Given I have the Blimpfile:
      """
      # Empty!
      """
    When I run `blimpy status`
    Then the exit status should be 0
    And the output should contain:
      """
      No currently running VMs
      """

  Scenario: With a running VM
    Given I have a single VM running
    When I run `blimpy status`
    Then the exit status should be 0
    And the output should list the VM
