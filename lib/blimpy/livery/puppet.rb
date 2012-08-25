require 'blimpy/livery/base'
require 'blimpy/livery/cwd'

module Blimpy
  module Livery
    class Puppet < CWD
      attr_accessor :module_path, :manifest_path, :options

      def initialize(*args)
        super
        @module_path = './modules'
        @manifest_path = 'manifests/site.pp'
        @options = '--verbose'
        @puppet_exists = false
      end

      def script
        'puppet.sh'
      end

      def preflight(box)
        # If we find Puppet in our default path, we don't really need to send
        # the bootstrap script again
        @puppet_exists = box.ssh_into('which puppet > /dev/null')
        unless @puppet_exists
          super(box)
        end
      end

      def flight(box)
        unless @puppet_exists
          # This should get our puppet.sh bootstrap script run
          super(box)
        end

        # At this point we should be safe to actually invoke Puppet
        command = "puppet apply --modulepath=#{module_path} #{options} #{manifest_path}"

        run_sudo = ''
        run_sudo = 'sudo' if use_sudo?(box)

        box.ssh_into("cd #{dir_name} && #{run_sudo} #{command}")
      end

      def postflight(box)
      end

      def bootstrap_script
        File.expand_path(File.dirname(__FILE__) + "/../../../scripts/#{script}")
      end

      def self.configure(&block)
        if block.nil?
          raise Blimpy::InvalidLiveryException, "Puppet livery must be given a block in order to configure itself"
        end
        instance = self.new
        yield instance
        instance
      end


    end
  end
end
