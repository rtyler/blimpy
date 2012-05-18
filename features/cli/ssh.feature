Feature: SSH into a named VM
  In order to directly access running VMs
  As a Blimpy user
  I should be able to run `blimpy ssh <name>` and be logged in

  Scenario: SSHing with an invalid name
    Given I have the Blimpfile:
      """
      Blimpy.fleet do |f|
        f.add(:aws) do |host|
          host.name = 'Cucumber Host'
        end
      end
      """
    When I run `blimpy ssh Gherkins`
    Then the exit status should be 1
    And the output should contain:
      """
      Could not find a blimp named "Gherkins"
      """


  # This test is really frustrating and I can't get aruba and the ssh code
  # to work together here :-/
  @slow @destroy @wip
  Scenario: SSHing into a remote host should work
    Given I have the Blimpfile:
      """
      Blimpy.fleet do |f|
        f.add(:aws) do |host|
          host.group = 'Simple'
          host.name = 'Cucumber Host'
        end
      end
      """
    When I ssh into the machine
    And I type "hostname -f"
    And I type "exit"
    Then the output should contain the right DNS info
