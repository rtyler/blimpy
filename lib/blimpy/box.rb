
module Blimpy
  class Box
    attr_reader :allowed_regions, :region, :server
    attr_accessor :image_id, :livery, :group, :name, :tags, :fleet_id

    def initialize
      @allowed_regions = ['us-west-1', 'us-west-2', 'us-east-1']
      @region = 'us-west-2' # Default to US West (Oregon) for now
      @image_id = 'ami-349b495d' # Default to Ubuntu 10.04 LTS (64bit)
      @livery = nil
      @group = nil
      @name = 'Unnamed Box'
      @tags = {}
      @instance_id = nil
      @server = nil
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

    def start
      ensure_state_dir
      @server = create_host

      File.open(File.join(state_dir, state_file), 'w') do |f|
        f.write("#{@name}\n")
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
      Fog::Compute[:aws].servers.create(:image_id => @image_id, :region => @region, :tags => tags)
    end
  end
end
