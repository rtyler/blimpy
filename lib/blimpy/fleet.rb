require 'blimpy/helpers/state'
require 'blimpy/boxes/aws'
require 'blimpy/boxes/openstack'

module Blimpy
  class Fleet
    include Blimpy::Helpers::State

    attr_reader :ships, :id

    def initialize
      @ships = []
      @id = Time.now.utc.to_i
      @airborn = false
    end

    def valid_types
      [:aws, :openstack]
    end

    def add(box_type, &block)
      unless valid_types.include? box_type
        raise Blimpy::InvalidShipException
      end
      if block.nil?
        return false
      end

      box = nil
      if box_type == :aws
        box = Blimpy::Boxes::AWS.new
      end
      if box_type == :openstack
        box = Blimpy::Boxes::OpenStack.new
      end

      if box.nil?
        return false
      end
      box.fleet_id = @id
      @ships << box
      block.call(box)
    end

    def state_file
      File.join(state_folder, 'manifest')
    end

    def save!
      File.open(state_file, 'w') do |f|
        f.write("id=#{id}\n")
      end
    end

    def resume(instances)
      boxes = []
      print '>> Resuming: '
      instances.each do |instance_id, instance_data|
        print "#{instance_data[:name]},"
        box = Blimpy::Box.from_instance_id(instance_id, instance_data)
        box.resume
        boxes << box
      end

      boxes.each do |box|
        box.wait_for_state('running') { print '.' }
      end
      puts
    end

    def animate
      buffer ="""
            _..--=--..._
          .-'            '-.  .-.
        /.'              '.\\/  /
        |=-  B L I M P Y   -=| (
        \\'.              .'/\\  \\
          '-.,_____ _____.-'  '-'
              [_____]=+ ~ ~"""
      frames = [
        'x~   ',
        'x ~  ',
        '+~ ~ ',
        '+ ~ ~',
        '+  ~ ',
        'x   ~',
      ]

      print buffer
      $stdout.flush
      until @airborn do
        frames.each do |frame|
          # Reset every frame
          5.times { print "\b" }
          print frame
          $stdout.flush
          sleep 0.2
        end
      end
    end

    def start
      instances = members
      unless instances.empty?
        return resume(instances)
      end

      # Make sure all our ships are valid first!
      @ships.each do |host|
        host.validate!
      end

      Thread.new do
        animate
      end

      @ships.each do |host|
        host.start
      end

      @ships.each do |host|
        host.wait_for_state('running') {  }
        @airborn = true
        print "\n"
        puts ">> #{host.name} online at: #{host.dns}"
        host.online!
        if host.provision_on_start
          host.bootstrap
          puts
        end
      end

      save!
    end

    def members
      instances = []
      Dir["#{Dir.pwd}/.blimpy.d/*.blimp"].each do |d|
        filename = File.basename(d)
        instance_id = filename.split('.blimp').first
        instance_data = YAML.load_file(d)
        instances << [instance_id, instance_data]
      end
      instances
    end

    def stop
      print '>> Stopping: '
      boxes = []

      members.each do |instance_id, instance_data|
        box = Blimpy::Box.from_instance_id(instance_id, instance_data)
        print "#{instance_data[:name]},"
        box.stop
        boxes << box
      end

      boxes.each do |box|
        box.wait_for_state('stopped')  { print '.' }
      end
      puts
    end

    def destroy
      members.each do |instance_id, instance_data|
        box = Blimpy::Box.from_instance_id(instance_id, instance_data)
        box.destroy
      end

      if File.exists? state_file
        File.unlink(state_file)
      end
    end
  end
end
