require 'rubygems'
require 'yaml'
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
    attr_accessor :dns, :internal_dns
    attr_accessor :name, :tags, :fleet_id, :username, :livery
    attr_accessor :provision_on_start

    def self.from_instance_id(an_id, data)
      return if data[:type].nil?

      name = data[:type].to_sym
      return unless Blimpy::Boxes.const_defined? name

      klass = Blimpy::Boxes.const_get(name)

      server = klass.fog_server_for_instance(an_id, data)
      return if server.nil?

      box = klass.new(server)
      box.with_data(an_id, data)
      box
    end

    def initialize(server=nil)
      @provision_on_start = true
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
      write_state_file
    end

    def validate!
      raise NotImplementedError, '#validate! should be defined in a subclass of Blimpy::Box'
    end

    def prestart
    end

    def start
      ensure_state_folder
      prestart
      @server = create_host
      poststart
      write_state_file
    end

    def poststart
    end

    def bootstrap
      @exec_commands = false
      if @livery.nil?
        return
      end

      if @livery.respond_to? :new
        @livery = @livery.new
      end

      wait_for_sshd
      bootstrap_livery
    end

    # This is just here to make things more consistent from an API perspective
    def provision
      bootstrap
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

    def predestroy
    end

    def destroy
      unless @server.nil?
        predestroy
        @server.destroy
        postdestroy
        File.unlink(state_file)
      end
    end

    def postdestroy
    end

    def type
      # We only really care about the class name as part of the Blimpy::Boxes
      # module
      self.class.to_s.split('::').last
    end

    def serializable_attributes
      [:type, :name, :region, :dns, :internal_dns, :flavor, :tags]
    end

    def immutable_attributes
      [:type]
    end

    def write_state_file
      data = {}
      serializable_attributes.each do |attr|
        data[attr] = self.send(attr)
      end
      File.open(state_file, 'w') do |f|
        f.write(data.to_yaml)
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
      data.each do |key, value|
        next if immutable_attributes.include? key.to_sym
        self.send("#{key}=", value)
      end
    end

    def dns
      @dns ||= begin
          if @server.nil?
            'no name'
          else
            @server.dns_name
          end
        end
    end

    def internal_dns
      @internal_dns ||= begin
                          if @server.nil?
                            'no name'
                          else
                            @server.private_dns_name
                          end
                        end
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
      run_command('ssh', '-o', 'PasswordAuthentication=no',
                  '-o', 'StrictHostKeyChecking=no',
                  '-l', username, dns, *args)
    end

    def scp_file(filename, directory='', *args)
      filename = File.expand_path(filename)
      run_command('scp', '-o', 'StrictHostKeyChecking=no',
                  filename, "#{username}@#{dns}:#{directory}", *args)
    end

    def bootstrap_livery
      if @livery.kind_of? Symbol
        raise Blimpy::InvalidLiveryException, 'Symbol liveries are unsupported!'
      end

      @livery.setup_on(self)
      @livery.preflight(self)
      @livery.flight(self)
      @livery.postflight(self)
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
