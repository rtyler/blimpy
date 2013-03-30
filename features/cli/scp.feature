Feature: SCP a file into a named VM
  In order to easily copy files from my local host to the named VM
  As a Blimpy user
  I should be able to run `blimpy scp <name> <file> [dest]`

  Scenario: SCPing with an invalid blimp name
    Given I have the Blimpfile:
      """
      Blimpy.fleet do |f|
        f.add(:aws) do |host|
          host.name = 'Cucumber Host'
        end
      end
      """
    And I have a file named "hello.txt"
    When I run `blimpy scp Gherkins hello.txt`
    Then the exit status should be 1
    And the output should contain:
      """
      Could not find a blimp named "Gherkins"
      """

  # This test is in the same boat that the complimentary test in ssh.feature is
  # in.
  @slow @destroy
  Scenario: SCPing a valid file
    Given I have the Blimpfile:
      """
      Blimpy.fleet do |f|
        f.add(:aws) do |host|
          host.name = 'Cucumber Host'
        end
      end
      """
    And I have a file named "hello.txt"
    And I run `blimpy start`
    When I run `blimpy scp "Cucumber Host" hello.txt`
    Then the exit status should be 0
