require 'rubygems'
require 'thor'

require 'blimpy'

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

      def load_blimpfile
        Blimpy.load_file(File.open(BLIMPFILE).read)
      end

      def box_by_name(name)
        fleet = load_blimpfile
        box = nil
        ship_id = nil
        data = nil
        fleet.members.each do |instance_id, instance_data|
          next unless instance_data[:name] == name
          ship_id = instance_id
          data = instance_data
          break
        end

        if ship_id.nil?
          return nil
        end

        fleet.ships.each do |ship|
          next unless ship.name == name
          ship.with_data(ship_id, data)
          return ship
        end
      end

      def current_blimps
        blimps = Dir["#{Dir.pwd}/.blimpy.d/*.blimp"]
        return false if blimps.empty?

        data = []
        blimps.each do |blimp|
          data << [blimp, YAML.load_file(blimp)]
        end
        data
      end

      def load_fleet
        ensure_blimpfile
        begin
          return load_blimpfile
        rescue Blimpy::InvalidBlimpFileError => e
          puts "The Blimpfile is invalid!"
          puts e.to_s
          return nil
        end
      end
    end

    desc 'start', 'Start up a fleet of blimps'
    method_options :"dry-run" => :boolean
    def start
      fleet = load_fleet

      if fleet.nil?
        exit 1
      end

      if options[:'dry-run']
        puts 'skipping actually starting the fleet'
        exit 0
      end

      fleet.start
    end

    desc 'resume', 'Resume an existing fleet of instances'
    def resume
      fleet = load_fleet

      if fleet.nil?
        exit 1
      end

      if fleet.members.empty?
        puts "No fleet running right now, perhaps you should `start` one."
        exit 1
      else
        fleet.resume(fleet.members)
      end
    end

    desc 'show', 'Show blimp details for running blimps'
    method_options :tags => :boolean
    def show
      ensure_blimpfile
      blimps = current_blimps
      unless blimps
        puts 'No currently running VMs'
        exit 0
      end

      tags_option = options[:tags]
      blimps.each do |blimp, data|
        if tags_option
          tags = nil
          data[:tags].each do |k,v|
            if tags.nil?
              tags = "#{k}=#{v}"
            elsif
              tags = "#{tags},#{k}=#{v}"
            end
          end
          puts "#{data[:name]} #{data[:internal_dns]} #{tags}"
        end
      end
    end

    desc 'status', 'Show running blimps'
    def status
      ensure_blimpfile
      blimps = current_blimps
      unless blimps
        puts 'No currently running VMs'
        exit 0
      end

      blimps.each do |blimp, data|
        instance_id = File.basename(blimp)
        instance_id = instance_id.split('.blimp').first
        puts "#{data[:name]} (#{instance_id}) is: online at #{data[:dns]} (#{data[:internal_dns]} internally)"
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
  fleet.add(:aws) do |ship|
    ship.name = 'Excelsior'
    ship.ports = [22, 8080]
  end
end
""")
      end
    end

    desc 'ssh BLIMP_NAME', 'Log into a running blimp'
    def ssh(name=nil, *args)
      ensure_blimpfile
      unless name.nil?
        box = box_by_name(name)
        if box.nil?
          puts "Could not find a blimp named \"#{name}\""
          exit 1
        end
      else
        blimps = current_blimps
        unless blimps
          puts "No Blimps running!"
          exit 1
        end

        blimps.each do |blimp, data|
          next unless data[:name]
          box = box_by_name(data[:name])
        end
      end

      box.wait_for_sshd
      box.ssh_into *args
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
      # Pass any extra commands along to the `scp` invocation
      box.scp_file(filename, '', *ARGV[3..-1])
    end

    desc 'provision BLIMP_NAME', 'Run the livery again'
    def provision(name=nil)
      ensure_blimpfile
      unless name.nil?
        box = box_by_name(name)
        if box.nil?
          puts "Could not find a blimp named \"#{name}\""
          exit 1
        end
        box.bootstrap
      else
        blimps = current_blimps
        unless blimps
          puts "No Blimps running!"
          exit 1
        end

        blimps.each do |blimp, data|
          next unless data[:name]
          box = box_by_name(data[:name])
          box.bootstrap
        end
      end
    end

    desc 'version', 'Print the current Blimpy gem version'
    def version
      puts Blimpy::VERSION
    end
  end
end
