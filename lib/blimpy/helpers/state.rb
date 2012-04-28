module Blimpy
  module Helpers
    module State
      def state_folder
        File.join(Dir.pwd, '.blimpy.d')
      end

      def ensure_state_folder
        unless File.exist? state_folder
          Dir.mkdir(state_folder)
        end
      end

      def state_file
        raise NotImplementedError, '#state_file should be implemented in a consumer'
      end
    end
  end
end

