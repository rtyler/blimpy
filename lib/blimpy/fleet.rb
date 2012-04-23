
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
        puts
      end
    end

    def stop
      raise NotImplementedError
    end

    def destroy
      raise NotImplementedError
    end
  end
end
