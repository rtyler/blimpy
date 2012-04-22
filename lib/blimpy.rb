require 'blimpy/box'
require 'blimpy/engine'
require 'blimpy/fleet'
require 'blimpy/version'

module Blimpy
  def self.fleet
  end

  class InvalidBlimpFileError < Exception
  end
  class InvalidRegionError < Exception
  end
end
