
module Blimpy
  class Box
    attr_reader :allowed_regions, :region
    attr_accessor :image_id, :livery, :group, :name

    def initialize
      @allowed_regions = [:uswest, :useast]
      @region = :uswest # Default to US West for now
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

  end
end
