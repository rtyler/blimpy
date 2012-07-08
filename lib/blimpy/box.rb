require 'blimpy/helpers/state'
require 'blimpy/livery'
require 'blimpy/keys'
require 'blimpy/securitygroups'
require 'blimpy/boxes'

module Blimpy
  class Box
    include Blimpy::Helpers::State

    attr_reader :allowed_regions, :region
    attr_accessor :image_id, :flavor, :group, :ports
    attr_accessor :name, :tags, :fleet_id, :username, :livery


    def self.from_instance_id(an_id, data)
      return if data['type'].nil?

      name = data['type'].upcase.to_sym
      return unless Blimpy::Boxes.const_defined? name

      klass = Blimpy::Boxes.const_get(name)

      server = klass.fog_server_for_instance(an_id, data)
      return if server.nil?

      box = klass.new(server)
      box.name = data['name']
      box
    end

    def initialize(server=nil)
      @livery = nil
      @group = nil
      @name = 'Unnamed Box'
      @tags = {}
      @ports = []
      @server = server
      @fleet_id = 0
      @ssh_connected = false
      @exec_commands = true
    end

    def region=(newRegion)
      unless (@allowed_regions.nil?) || (@allowed_regions.include?(newRegion))
        raise InvalidRegionError
      end
      @region = newRegion
    end

    def online!
      File.open(state_file, 'a') do |f|
        f.write("dns: #{@server.dns_name}\n")
        f.write("internal_dns: #{@server.private_dns_name}\n")
      end
    end

    def validate!
      raise NotImplementedError, '#validate! should be defined in a subclass of Blimpy::Box'
    end

    def start
      ensure_state_folder
      @server = create_host
      write_state_file
    end

    def bootstrap
      @exec_commands = false
      unless livery.nil?
        wait_for_sshd
        bootstrap_livery
      end
    end

    def stop
      unless @server.nil?
        @server.stop
      end
    end

    def resume
      unless @server.nil?
        @server.start
      end
    end

    def destroy
      unless @server.nil?
        @server.destroy
        File.unlink(state_file)
      end
    end

    def write_state_file
      File.open(state_file, 'w') do |f|
        # We only really care about the class name as part of the Blimpy::Boxes
        # module
        f.write("type: #{self.class.to_s.split('::').last}\n")
        f.write("name: #{@name}\n")
        f.write("region: #{@region}\n")
      end
    end

    def state_file
      if @server.nil?
        raise Exception, "I can't make a state file without a @server!"
      end
      File.join(state_folder, "#{@server.id}.blimp")
    end

    def wait_for_state(until_state, &block)
      if @server.nil?
        return
      end

      @server.wait_for do
        block.call
        state == until_state
      end
    end


    def with_data(ship_id, data)
      @dns = data['dns']
      @region = data['region']
    end

    def dns_name
      @dns ||= begin
          if @server.nil?
            'no name'
          else
            @server.dns_name
          end
        end
    end

    def internal_dns_name
      return @server.private_dns_name unless @server.nil?
      'no name'
    end

    def run_command(*args)
      if @exec_commands
        ::Kernel.exec(*args)
      else
        ::Kernel.system(*args)
      end
    end

    def ssh_into(*args)
      # Support using #ssh_into within our own code as well to pass arguments
      # to the ssh(1) binary
      if args.empty?
        args = ARGV[2 .. -1]
      end
      run_command('ssh', '-o', 'StrictHostKeyChecking=no',
                  '-l', username, dns_name, *args)
    end

    def scp_file(filename)
      filename = File.expand_path(filename)
      run_command('scp', '-o', 'StrictHostKeyChecking=no',
                  filename, "#{username}@#{dns_name}:", *ARGV[3..-1])
    end

    def bootstrap_livery
      if livery == :cwd
        dir_name = File.basename(Dir.pwd)
        run_command('rsync', '-avL',
                    '--exclude=.git',
                    '--exclude=.svn',
                    '--exclude=.blimpy.d',
                    '.',
                    "#{username}@#{dns_name}:#{dir_name}/")
        puts 'Bootstrapping the livery'
        run_sudo = 'sudo'
        if username == 'root'
          run_sudo = ''
        end
        ssh_into("cd #{dir_name} && #{run_sudo} ./bootstrap.sh")
      end
    end

    def wait_for_sshd
      return if @ssh_connected
      start = Time.now.to_i
      use_exec = @exec_commands
      # Even if we are supposed to use #exec here, we wait to disable it until
      # after sshd(8) comes online
      @exec_commands = false

      until @ssh_connected
        # Run the `true` command and exit
        @ssh_connected = ssh_into('-q', 'true')

        unless @ssh_connected
          if (Time.now.to_i - start) < 60
            print '.'
            sleep 1
          end
        end
      end
      puts
      @exec_commands = use_exec
    end

    def fog
      raise NotImplementedError, '#fog should be implemented by cloud-specific subclasses'
    end

    private

    def create_host
      raise NotImplementedError, '#create_host should be implemented by a cloud-specific subclass'
    end
  end
end
