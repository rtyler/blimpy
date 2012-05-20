Feature: Start a VM or cluster of VMs in the cloud

  Scenario: Without a Blimpfile
    Given I have no Blimpfile in my current directory
    When I run `blimpy start`
    Then the output should contain:
      """
      Please create a Blimpfile in your current directory
      """
    And the exit status should be 1

  Scenario: dry-run start with a simple Blimpfile
    Given I have the Blimpfile:
      """
      Blimpy.fleet do |f|
        f.add(:aws) do |host|
          host.group = 'Simple'
          host.name = 'Cucumber Host'
        end
      end
      """
    When I run `blimpy start --dry-run`
    Then the exit status should be 0
    And the output should contain:
      """
      skipping actually starting the fleet
      """

  Scenario: Start with an invalid Blimpfile
    Given I have the Blimpfile:
      """
        Blimpy.fleet do |f|
          f.bork
        end
      """
    When I run `blimpy start`
    Then the exit status should be 1
    And the output should contain:
      """
      The Blimpfile is invalid!
      """

  @slow @destroy
  Scenario: start with a functional Blimpfile
    Given I have the Blimpfile:
      """
      Blimpy.fleet do |f|
        f.add(:aws) do |host|
          host.group = 'Simple'
          host.name = 'Cucumber Host'
        end
      end
      """
    When I run `blimpy start`
    Then the exit status should be 0
    And the output should contain:
      """
      online at:
      """

  @slow @destroy
  Scenario: Start a bigger instance
    Given I have the Blimpfile:
      """
      Blimpy.fleet do |f|
        f.add(:aws) do |host|
          host.name = 'Cucumber Host'
          host.flavor = 'm1.large'
        end
      end
      """
    When I run `blimpy start`
    Then the exit status should be 0

  @slow @destroy @openstack @wip
  Scenario: start with an OpenStack Blimpfile
    Given I have the Blimpfile:
      """
      Blimpy.fleet do |f|
        f.add(:openstack) do |host|
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
    And the output should contain:
      """
      online at:
      """
