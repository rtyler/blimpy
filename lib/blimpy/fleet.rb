
module Blimpy
  class Fleet
    attr_reader :hosts

    def initialize
      @hosts = []
      @servers = []
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

    def start
      # Make sure all our hosts are valid first!
      @hosts.each do |host|
        host.validate!
      end

      @hosts.each do |host|
        @servers << host.start
      end

      @hosts.each do |host|
        print ">> #{host.name} "
        host.server.wait_for do
          print '.'
          ready?
        end
        print ".. online at: #{host.server.dns_name}"
        host.online!
        puts
      end
    end

    def members
      instance_ids = []
      Dir["#{Dir.pwd}/.blimpy.d/*.blimp"].each do |d|
        filename = File.basename(d)
        instance_ids << filename.split('.blimp').first
      end
      instance_ids
    end

    def stop
      members.each do |instance_id|
        box = Blimpy::Box.from_instance_id(instance_id)
        box.stop
      end
    end

    def destroy
      members.each do |instance_id|
        box = Blimpy::Box.from_instance_id(instance_id)
        box.destroy
      end
    end
  end
end
