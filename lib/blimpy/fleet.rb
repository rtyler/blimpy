require 'blimpy/helpers/state'

module Blimpy
  class Fleet
    include Blimpy::Helpers::State

    attr_reader :ships, :id

    def initialize
      @ships = []
      @id = Time.now.utc.to_i
    end

    def valid_types
      [:aws]
    end

    def add(box_type, &block)
      unless valid_types.include? box_type
        raise Blimpy::InvalidShipException
      end
      if block.nil?
        return false
      end
      box = Blimpy::Box.new
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
        print "#{instance_data['name']},"
        box = Blimpy::Box.from_instance_id(instance_id, instance_data)
        box.resume
        boxes << box
      end

      boxes.each do |box|
        box.wait_for_state('running') { print '.' }
      end
      puts
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

      puts '>> Starting:'
      @ships.each do |host|
        puts "..#{host.name}"
        host.start
      end

      @ships.each do |host|
        print ">> #{host.name} "
        host.wait_for_state('running') { print '.' }
        print ".. online at: #{host.dns_name}"
        host.online!
        host.bootstrap
        puts
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
        print "#{instance_data['name']},"
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
