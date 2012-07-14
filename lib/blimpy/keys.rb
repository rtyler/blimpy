require 'fog'
require 'socket'

module Blimpy
  module Keys
    def self.public_key
      filename = File.expand_path('~/.ssh/id_rsa.pub')
      unless File.exists? filename
        filename = File.expand_path('~/.ssh/id_dsa.pub')
        unless File.exists? filename
          raise Blimpy::SSHKeyNotFoundError, 'Expected either ~/.ssh/id_rsa.pub or ~/.ssh/id_dsa.pub but found neither'
        end
      end

      File.open(filename, 'r').read
    end

    def self.key_name
      "Blimpy-#{ENV['USER']}-#{Socket.gethostname}"
    end
  end
end
