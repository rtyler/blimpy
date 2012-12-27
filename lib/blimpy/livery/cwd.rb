require 'blimpy/livery/base'

module Blimpy
  module Livery
    class CWD < Base
      def script
        'bootstrap.sh'
      end

      def preflight(box)
        box.scp_file(bootstrap_script, dir_name)
      end

      def use_sudo?(box)
        box.username != 'root'
      end

      def flight(box)
        run_sudo = 'sudo'

        unless use_sudo?(box)
          run_sudo = ''
        end

        box.ssh_into("cd #{dir_name} && #{run_sudo} BLIMPY_SHIPNAME=#{box.name} ./#{script}")
      end

      def bootstrap_script
        File.join(livery_root, script)
      end
    end
  end
end
