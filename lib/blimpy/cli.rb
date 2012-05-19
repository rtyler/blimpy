require 'rubygems'
require 'thor'

require 'blimpy'
require 'blimpy/engine'

module Blimpy
  class CLI < Thor
    BLIMPFILE = File.join(Dir.pwd, 'Blimpfile')

    no_tasks do
      def ensure_blimpfile
        unless File.exists? Blimpy::CLI::BLIMPFILE
          puts 'Please create a Blimpfile in your current directory'
          exit 1
        end
      end

      def load_engine
        engine = Blimpy::Engine.new
        engine.load_file(File.open(BLIMPFILE).read)
        engine
      end


      def box_by_name(name)
        engine = load_engine
        box = nil
        id = nil
        data = nil
        engine.fleet.members.each do |instance_id, instance_data|
          next unless instance_data['name'] == name
          id = instance_id
          data = instance_data
          break
        end

        if id.nil?
          return nil
        end

        engine.fleet.ships.each do |ship|
          next unless ship.name == name
          ship.server = ship.class.fog_server_for_instance(id, data)
          box = ship
        end
        box
      end
    end

    desc 'start', 'Start up a fleet of blimps'
    method_options :"dry-run" => :boolean
    def start
      ensure_blimpfile
      engine = load_engine
      puts 'Up, up and away!'

      if options[:'dry-run']
        puts 'skipping actually starting the fleet'
        exit 0
      end

      engine.fleet.start
    end

    desc 'status', 'Show running blimps'
    def status
      ensure_blimpfile
      blimps = Dir["#{Dir.pwd}/.blimpy.d/*.blimp"]
      if blimps.empty?
        puts 'No currently running VMs'
        exit 0
      end

      blimps.each do |blimp|
        data = YAML.load_file(blimp)
        instance_id = File.basename(blimp)
        instance_id = instance_id.split('.blimp').first
        puts "#{data['name']} (#{instance_id}) is: online at #{data['dns']}"
      end
    end

    desc 'destroy', 'Destroy all running blimps'
    def destroy
      ensure_blimpfile
      fleet = Blimpy::Fleet.new
      fleet.destroy
    end

    desc 'stop', 'Stop the running blimps'
    def stop
      ensure_blimpfile
      fleet = Blimpy::Fleet.new
      fleet.stop
    end

    desc 'init', 'Create a skeleton Blimpfile in the current directory'
    def init
      File.open(File.join(Dir.pwd, 'Blimpfile'), 'w') do |f|
        f.write(
"""# vim: ft=ruby
# Blimpfile created on #{Time.now}

Blimpy.fleet do |fleet|
  fleet.add do |ship|
    ship.name = 'Excelsior'
    ship.group = 'default'
  end
end
""")
      end
    end

    desc 'ssh BLIMP_NAME', 'Log into a running blimp'
    def ssh(name, *args)
      ensure_blimpfile
      box = box_by_name(name)
      if box.nil?
        puts "Could not find a blimp named \"#{name}\""
        exit 1
      end
      box.wait_for_sshd
      box.ssh_into
    end

    desc 'scp BLIMP_NAME FILE_NAME', 'Securely copy FILE_NAME into the blimp'
    def scp(name, filename, *args)
      ensure_blimpfile
      box = box_by_name(name)
      if box.nil?
        puts "Could not find a blimp named \"#{name}\""
        exit 1
      end
      box.wait_for_sshd
      box.scp_file(filename)
    end

    desc 'provision BLIMP_NAME', 'Run the livery again'
    def provision(name=nil)
      ensure_blimpfile
      box = box_by_name(name)
      if box.nil?
        puts "Could not find a blimp named \"#{name}\""
        exit 1
      end
      box.bootstrap
    end
  end
end
