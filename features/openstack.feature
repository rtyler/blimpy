Feature: Provision machines on an OpenStack cluster
  In order to use a private cloud, powered by OpenStack
  As a Blimpy user
  I should be able to tspin up machines on OpenStack the same way I am able to
  on AWS


  @slow @destroy @openstack
  Scenario: Start with a functional Blimpfile
    Given I have the Blimpfile:
      """
      Blimpy.fleet do |f|
        f.add(:openstack) do |host|
          host.name = 'Cucumber Host'
          host.image_id = '5e624061-65cc-4e67-b6c5-8e7ac6e38ea7' # Maps to our intenral 'lucid-server' image
          host.region = 'test' # This is the "test" tenant
          host.flavor = 'm1.tiny'
        end
      end
      """
    When I run `blimpy start`
    Then the exit status should be 0
    And the output should contain:
      """
      online at:
      """
