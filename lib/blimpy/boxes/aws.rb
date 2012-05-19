require 'blimpy/box'
require 'blimpy/boxes'

module Blimpy::Boxes
  class AWS < Blimpy::Box
    # Default to US West (Oregon)
    DEFAULT_REGION = 'us-west-2'
    # Default to 10.04 64-bit
    DEFAULT_IMAGE_ID = 'ami-ec0b86dc'

    def self.fog_server_for_instance(id, blimpdata)
      region = blimpdata['region'] || DEFAULT_REGION
      fog = Fog::Compute.new(:provider => 'AWS', :region => region)
      fog.servers.get(id)
    end

    def initialize(server=nil)
      super(server)
      @allowed_regions = ['us-west-1', 'us-west-2', 'us-east-1']
      @region = DEFAULT_REGION
      @image_id = DEFAULT_IMAGE_ID
      @username = 'ubuntu'
    end

    def validate!
      if Fog::Compute[:aws].security_groups.get(@group).nil?
        raise Blimpy::BoxValidationError
      end
    end
  end
end
