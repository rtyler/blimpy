
module Blimpy
  class Box
    # Default to US West (Oregon)
    DEFAULT_REGION = 'us-west-2'
    # Default to 10.04 64-bit
    DEFAULT_IMAGE_ID = 'ami-ec0b86dc'

    attr_reader :allowed_regions, :region, :server
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
      File.open(File.join(state_dir, state_file), 'a') do |f|
        f.write("dns: #{@server.dns_name}\n")
      end
    end

    def start
      ensure_state_dir
      @server = create_host

      File.open(File.join(state_dir, state_file), 'w') do |f|
        f.write("name: #{@name}\n")
        f.write("region: #{@region}\n")
      end
    end

    def stop
      unless @server.nil?
        @server.stop
      end
    end

    def destroy
      unless @server.nil?
        @server.destroy
        File.unlink(File.join(state_dir, state_file))
      end
    end

    def state_dir
      File.join(Dir.pwd, '.blimpy.d')
    end

    def state_file
      if @server.nil?
        raise Exception, "I can't make a state file without a @server!"
      end
      "#{@server.id}.blimp"
    end

    def ensure_state_dir
      unless File.exist? state_dir
        Dir.mkdir(state_dir)
      end
    end

    private

    def create_host
      tags = @tags.merge({:Name => @name, :CreatedBy => 'Blimpy', :BlimpyFleetId => @fleet_id})
      if @fog.nil?
        @fog = Fog::Compute.new(:provider => 'AWS', :region => @region)
      end
      @fog.servers.create(:image_id => @image_id, :tags => tags)
    end
  end
end
