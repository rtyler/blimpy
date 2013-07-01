Feature: Resume a VM or VMs that were previously stopped

  Scenario: Resume without stopped Blimps
    Given I have the Blimpfile:
      """
        Blimpy.fleet do |f|
          f.add(:aws) do |host|
            host.name = 'Cucumber Host'
          end
        end
      """
    When I run `blimpy resume`
    Then the exit status should be 1
    And the output should contain:
      """
      No fleet running right now, perhaps you should `start` one.
      """
