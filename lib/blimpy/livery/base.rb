
module Blimpy
  module Livery
    class Base
      def preflight(*args)
      end

      def flight(*args)
        raise NotImplementedError
      end

      def postflight(*args)
      end

      def rsync_excludes
        ['.git', '.svn', '.blimpy.d']
      end

      def rsync_command
        excludes = rsync_excludes.map { |x| "--exclude=#{x}" }
        ['rsync',
         '-avL',
         '-e',
         'ssh -o StrictHostKeyChecking=no'] + excludes
      end

      def sync_to(box)
        if can_rsync?
          command = rsync_command + ['.', "#{box.username}@#{box.dns}:#{dir_name}/"]
          box.run_command(*command)
        else
          puts "Remote host has no rsync(1), falling back to copying a full tarball over"
          tarball = Blimpy::Livery.tarball_directory(livery_root)
          box.scp_file(tarball)
          # HAXX
          basename = File.basename(tarball)
          box.ssh_into("tar -zxf #{basename} && cd #{dir_name}")
        end

      end

      def livery_root
        Dir.pwd
      end

      def dir_name
        File.basename(livery_root)
      end

      def setup_on(box)
        sync_to(box)
      end
    end
  end
end
