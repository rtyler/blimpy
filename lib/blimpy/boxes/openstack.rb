require 'blimpy/box'
require 'blimpy/boxes'

module Blimpy::Boxes
  class OpenStack < Blimpy::Box
    def self.fog_server_for_instance(id, blimpdata)
      region = blimpdata[:region]
      fog = Fog::Compute.new(:provider => 'OpenStack', :openstack_tenant => region)
      fog.servers.get(id)
    end

    class FloatingIp
      attr_accessor :address, :id

      def initialize(address, id)
        @address = address
        @id = id
      end

      def to_yaml(*args)
        {:address => address, :id => id}.to_yaml
      end
    end

    attr_accessor :key_name, :floating_ip

    def initialize(server=nil)
      super(server)
      @username = 'ubuntu'
      @flavor = 'm1.tiny'
      @group = 'default'
      @key_name = nil
      @floating_ip = nil
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

    def serializable_attributes
      super + [:network]
    end

    def network
      floating_ip
    end

    def network=(floating_hash)
      floating_ip = FloatingIp.new(floating_hash['address'], floating_hash['id'])
    end

    def dns
      'unavailable'
    end

    def internal_dns
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

    def prestart
      allocate_ip
    end

    def poststart
      associate_ip
    end

    def allocate_ip
      response = fog.allocate_address
      unless response.status == 200
        raise Blimpy::UnknownError, "Blimpy was unable to allocate a floating IP address; #{response.inspect}"
      end

      details = response.body['floating_ip']
      @floating_ip = FloatingIp.new(details['ip'], details['id'])
    end

    def associate_ip
      if floating_ip.nil?
        raise Blimpy::UnknownError, "Blimpy cannot associate a floating IP until it's been allocated properly!"
      end
      response = fog.associate_address(image_id, floating_ip.address)

      unless response.status == 202
        raise Blimpy::UnknownError, "Blimpy failed to associate the IP somehow #{response.inspect}"
      end
    end

    def predestroy
      disassociate_ip unless floating_ip.nil?
    end

    def disassociate_ip
      fog.disassociate_address(image_id, floating_ip.address)
    end

    def postdestroy
      deallocate_ip unless floating_ip.nil?
    end

    def deallocate_ip
      fog.release_address(floating_ip.id)
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
      fog.servers.create(:image_ref => image_id,
                         :flavor_ref => flavor_id(@flavor),
                         :key_name => Blimpy::Keys.key_name,
                         :groups => groups,
                         :name => @name,
                         :tags => tags)
    end
  end
end
