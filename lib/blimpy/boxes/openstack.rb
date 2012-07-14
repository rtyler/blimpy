require 'blimpy/box'
require 'blimpy/boxes'

module Blimpy::Boxes
  class OpenStack < Blimpy::Box
    def self.fog_server_for_instance(id, blimpdata)
      region = blimpdata['region']
      fog = Fog::Compute.new(:provider => 'OpenStack', :openstack_tenant => region)
      fog.servers.get(id)
    end

    attr_accessor :key_name

    def initialize(server=nil)
      super(server)
      @username = 'ubuntu'
      @flavor = 'm1.tiny'
      @group = 'default'
      @key_name = nil
    end

    def ports=(new_pors)
      raise Blimpy::UnsupportedFeatureException, 'Opening arbitrary ports in OpenStack is currently not supported'
    end

    def wait_for_state(until_state, &block)
      until @server.ready?
        sleep 1
        @server.reload
      end
    end

    def dns_name
      'unavailable'
    end

    def internal_dns_name
      'unavailable'
    end

    def validate!
      if @region.nil?
        raise Blimpy::BoxValidationError, "Cannot spin up machine without a set region"
      end

      if flavor_id(@flavor).nil?
        raise Blimpy::BoxValidationError, "'#{@flavor}' is not a valid OpenStack tenant name"
      end
    end

    def fog
      @fog ||= begin
        Fog::Compute.new(:provider => 'openstack', :openstack_tenant => @region)
      end
    end

    def flavors
      @flavors ||= fog.flavors
    end

    def flavor_id(name)
      flavors.each do |flavor|
        return flavor.id if flavor.name == name
      end
      nil
    end

    private

    def import_key
      material = Blimpy::Keys.public_key
      begin
        fog.create_key_pair(Blimpy::Keys.key_name, material)
      rescue Excon::Errors::Conflict => e
      end
    end

    def create_host
      tags = @tags.merge({:Name => @name, :CreatedBy => 'Blimpy', :BlimpyFleetId => @fleet_id})

      groups = [@group]
      import_key
      fog.servers.create(:image_ref => @image_id,
                         :flavor_ref => flavor_id(@flavor),
                         :key_name => Blimpy::Keys.key_name,
                         :groups => groups,
                         :name => @name,
                         :tags => tags)
    end
  end
end
