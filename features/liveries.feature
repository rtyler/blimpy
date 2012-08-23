Feature: Craft machines based on a livery
  In order to bootstrap a machine that looks how I expect it to
  As a Blimpy user
  When I specify a specific livery then that livery should provision
  the host the way I would expect it to.

  @wip
  Scenario: Using a configuration-less livery
    Given the following Blimpfile contents:
      """
        Blimpy.fleet do |fleet|
          fleet.add(:aws) do |ship|
            ship.name = 'cucumber-livery'
            ship.livery = Blimpy::Livery::CWD
          end
        end
      """
    When I evaluate the Blimpfile
    Then the "CWD" livery should be set up

  @wip
  Scenario: Configuration-less liveries
    Given the following Blimpfile contents:
      """
        Blimpy.fleet do |fleet|
          fleet.add(:aws) do |ship|
            ship.name = 'cucumber-livery'
            ship.livery = Blimpy::Livery::Puppet.configure do |p|
              p.module_path = './modules'
              p.manifest_path = './test/site.pp'
              p.options = '--verbose'
            end
          end
        end
      """
    When I evaluate the Blimpfile
    Then the Puppet livery should be correctly configured
