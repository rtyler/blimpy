require 'set'
require 'zlib'

module Blimpy
  module SecurityGroups
    def self.group_id(ports)
      if ports.nil? or ports.empty?
        return nil
      end

      ports = Set.new(ports)
      # Lolwut, #hash is inconsistent between ruby processes
      "Blimpy-#{Zlib.crc32(ports.inspect)}"
    end
  end
end
