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

      def flight(box)
        run_sudo = 'sudo'

        if box.username == 'root'
          run_sudo = ''
        end

        box.ssh_into("cd #{dir_name} && #{run_sudo} ./#{script}")
      end

      def bootstrap_script
        File.join(livery_root, script)
      end
    end
  end
end
