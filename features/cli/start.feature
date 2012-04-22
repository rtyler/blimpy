Feature: Start a VM or cluster of VMs in the cloud

  Scenario: Without a Blimpfile
    Given I have no Blimpfile in my current directory
    When I run `blimpy start`
    Then the output should contain:
      """
      Please create a Blimpfile in your current directory
      """
    And the exit status should be 1

    Scenario: With a simple Blimpfile
      Given I have the Blimpfile:
        """
        Blimpy.fleet do |f|
          f.add do |host|
            host.group = 'Simple'
            host.name = 'Cucumber Host'
          end
        end
        """
      When I run `blimpy start`
      Then the exit status should be 0
      And the output should contain:
        """
        Up, up and away!
        """
