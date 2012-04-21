Feature: Start a VM or cluster of VMs in the cloud

  Scenario: Without a Blimpfile
    Given I have no Blimpfile in my current directory
    When I run `blimpy start`
    Then the output should contain:
      """
      Please create a Blimpfile in your current directory
      """
    And the exit status should be 1
