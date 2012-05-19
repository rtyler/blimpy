Feature: Run provisioning against running VMs
  In order to update the currently running VMs with new code/etc
  As a blimpy user
  I should be able to incrementally send updates to VMs and have the
  provisioning code run again

  Background: Ensure a simple Blimpfile
    Given I have the Blimpfile:
      """
      Blimpy.fleet do |fleet|
        fleet.add(:aws) do |blimp|
          blimp.name = 'provision-blimp'
        end
      end
      """

  Scenario: No arguments and no VMs
    When I run `blimpy provision`
    Then the exit status should be 1
    And the output should contain:
      """
      No Blimps running!
      """

  Scenario: Naming a blimp without running Blimps
    When I run `blimpy provision provision-blimp`
    Then the exit status should be 1
    And the output should contain:
      """
      Could not find a blimp named "provision-blimp"
      """
