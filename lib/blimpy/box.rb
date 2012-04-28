require 'blimpy/helpers/state'
require 'blimpy/keys'

module Blimpy
  class Box
    include Blimpy::Helpers::State

    # Default to US West (Oregon)
    DEFAULT_REGION = 'us-west-2'
    # Default to 10.04 64-bit
    DEFAULT_IMAGE_ID = 'ami-ec0b86dc'

    attr_reader :allowed_regions, :region
    attr_accessor :image_id, :livery, :group, :name, :tags, :fleet_id

    def self.from_instance_id(an_id, data)
      region = data['region'] || DEFAULT_REGION
      fog = Fog::Compute.new(:provider => 'AWS', :region => region)
      server = fog.servers.get(an_id)
      if server.nil?
        return nil
      end
      self.new(server)
    end

    def initialize(server=nil)
      @allowed_regions = ['us-west-1', 'us-west-2', 'us-east-1']
      @region = DEFAULT_REGION
      @image_id = DEFAULT_IMAGE_ID
      @livery = nil
      @group = nil
      @name = 'Unnamed Box'
      @tags = {}
      @server = server
      @fleet_id = 0
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

    def online!
      File.open(state_file, 'a') do |f|
        f.write("dns: #{@server.dns_name}\n")
      end
    end

    def start
      ensure_state_folder
      @server = create_host
      write_state_file
    end

    def stop
      unless @server.nil?
        @server.stop
      end
    end

    def resume
      unless @server.nil?
        @server.start
      end
    end

    def destroy
      unless @server.nil?
        @server.destroy
        File.unlink(state_file)
      end
    end

    def write_state_file
      File.open(state_file, 'w') do |f|
        f.write("name: #{@name}\n")
        f.write("region: #{@region}\n")
      end
    end


    def state_file
      if @server.nil?
        raise Exception, "I can't make a state file without a @server!"
      end
      File.join(state_folder, "#{@server.id}.blimp")
    end

    def wait_for_state(until_state, &block)
      if @server.nil?
        return
      end

      @server.wait_for do
        block.call
        state == until_state
      end
    end

    def dns_name
      return @server.dns_name  unless @server.nil?
      'no name'
    end

    private

    def create_host
      tags = @tags.merge({:Name => @name, :CreatedBy => 'Blimpy', :BlimpyFleetId => @fleet_id})
      if @fog.nil?
        @fog = Fog::Compute.new(:provider => 'AWS', :region => @region)
      end

      Blimpy::Keys.import_key(@fog)
      @fog.servers.create(:image_id => @image_id,
                          :key_name => Blimpy::Keys.key_name,
                          :groups => [@group],
                          :tags => tags)
    end
  end
end
