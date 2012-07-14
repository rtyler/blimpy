require 'blimpy/box'
require 'blimpy/engine'
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
end
