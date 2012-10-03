require 'set'
require 'zlib'

module Blimpy
  module SecurityGroups
    def self.group_id(ports)
      if ports.nil? or ports.empty?
        return nil
      end

      unless ports.is_a? Set
        ports = Set.new(ports)
      end

      # Lolwut, #hash is inconsistent between ruby processes
      "Blimpy-#{Zlib.crc32(ports.inspect)}"
    end

    def self.ensure_group(fog, ports)
      name = group_id(ports)

      exists = fog.security_groups.get(name)

      if exists.nil?
        name = create_group(fog, ports)
      end
      name
    end

    def self.create_group(fog, ports)
      name = group_id(ports)
      group = fog.security_groups.create(:name => name,
                                         :description => "Custom Blimpy security group for #{ports.to_a}")

      unless ports.is_a? Set
        ports = Set.new(ports)
      end

      ports.each do |port|
        group.authorize_port_range(port .. port)
      end
      name
    end
  end
end
