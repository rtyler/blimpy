require 'rubygems'
require 'fog/core'
require 'fog/compute'

require 'blimpy/box'
require 'blimpy/fleet'
require 'blimpy/version'

module Blimpy
  def self.fleet(&block)
    if block.nil?
      return false
    end
    fleet = Blimpy::Fleet.new
    block.call fleet
    fleet
  end

    def self.load_file(file_content)
      if file_content.nil? || file_content.empty?
        raise InvalidBlimpFileError, 'File appears empty'
      end

      begin
        fleet = eval(file_content)
        if fleet and !(fleet.instance_of? Blimpy::Fleet)
          raise Exception, 'File does not create a Fleet'
        end
      rescue Exception => e
        raise InvalidBlimpFileError, e.to_s
      end
      fleet
    end

  class UnknownError < Exception
  end
  class InvalidBlimpFileError < Exception
  end
  class InvalidRegionError < Exception
  end
  class BoxValidationError < Exception
  end
  class SSHKeyNotFoundError < Exception
  end
  class InvalidShipException < Exception
  end
  class UnsupportedFeatureException < Exception
  end
  class InvalidLiveryException < Exception; end;
end
