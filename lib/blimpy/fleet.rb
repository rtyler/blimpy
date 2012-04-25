
module Blimpy
  class Fleet
    attr_reader :hosts

    def initialize
      @hosts = []
      @id = Time.now.utc.to_i
    end

    def add(&block)
      if block.nil?
        return false
      end
      box = Blimpy::Box.new
      box.fleet_id = @id
      @hosts << box
      block.call(box)
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

      # Make sure all our hosts are valid first!
      @hosts.each do |host|
        host.validate!
      end

      @hosts.each do |host|
        print ">> #{host.name} "
        host.wait_for_state('running') { print '.' }
        print ".. online at: #{host.dns_name}"
        host.online!
        puts
      end
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
    end
  end
end
