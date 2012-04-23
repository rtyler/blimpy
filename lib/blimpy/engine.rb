
require 'rubygems'
require 'fog'

module Blimpy
  class Engine
    attr_reader :fleet

    def initialize
      @fleet = nil
    end

    def load_file(file_content)
      if file_content.nil? || file_content.empty?
        raise InvalidBlimpFileError, 'File appears empty'
      end

      begin
        @fleet = eval(file_content)
      rescue Exception => e
        raise InvalidBlimpFileError, e.to_s
      end
    end
  end
end
