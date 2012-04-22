
module Blimpy
  class Box
    attr_reader :allowed_regions, :region
    attr_accessor :image_id, :livery, :group, :name

    def initialize
      @allowed_regions = ['us-west-1', 'us-west-2', 'us-east-1']
      @region = 'us-west-2' # Default to US West (Oregon) for now
      @image_id = 'ami-349b495d' # Default to Ubuntu 10.04 LTS (64bit)
      @livery = nil
      @group = nil
      @name = 'Unnamed Box'
    end

    def region=(newRegion)
      unless @allowed_regions.include? newRegion
        raise InvalidRegionError
      end
      @region = newRegion
    end

    def validate!
      if Fog::Compute[:aws].security_groups.get(@group).nil?
        raise BoxValidationError
      end
    end
  end
end
