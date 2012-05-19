require 'blimpy/box'
require 'blimpy/boxes'

module Blimpy::Boxes
  class OpenStack < Blimpy::Box
    def self.fog_server_for_instance(id, blimpdata)
      region = blimpdata['region']
      fog = Fog::Compute.new(:provider => 'OpenStack', :region => region)
      fog.servers.get(id)
    end
  end
end
