require 'ostruct'
require 'fog/core/timeout'
require 'fog/core/wait_for'
require 'etc'

module Blimpy::Boxes
  # Fake box type for physical computer accessible through SSH
  class Existing < Blimpy::Box
    def self.fog_server_for_instance(id, blimpdata)
      ExistingServer.new(id)
    end

    def initialize(server=nil)
      super(server)
      @username = Etc.getlogin
    end

    def validate!
      if @name.nil?
        raise Blimpy::BoxValidationError, "Don't know which box to log into --- the host property is not set."
      end
    end

    def wait_for_state(until_state, &block)
      # this magical box type becomes any state instantly
    end

    private

    def create_host
      ExistingServer.new(@name)
    end
  end

  class ExistingServer
    def initialize(name)
      @name = name
    end
    def dns_name
      @name
    end
    def private_dns_name
      @name
    end
    def id
      @name
    end

    def wait_for(timeout=Fog.timeout, interval=1, &block)
      Fog.wait_for(timeout, interval, &block)
    end

    # no-ops
    def stop
    end
    def start
    end
    def destroy
    end
  end
end
