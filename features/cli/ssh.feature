Feature: SSH into a named VM
  In order to directly access running VMs
  As a Blimpy user
  I should be able to run `blimpy ssh <name>` and be logged in

  @slow @destroy @wip
  Scenario: SSHing into a remote host should work
    Given I have the Blimpfile:
      """
      Blimpy.fleet do |f|
        f.add do |host|
          host.group = 'Simple'
          host.name = 'Cucumber Host'
        end
      end
      """
    And I run `blimpy start`
    When I run `blimpy ssh "Cucumber Host"` interactively
    And I type "hostname -f"
    Then the output should contain the right DNS info
