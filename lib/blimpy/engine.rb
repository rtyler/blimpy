
require 'rubygems'
require 'fog/core'
require 'fog/compute'

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
        if @fleet and !(@fleet.instance_of? Blimpy::Fleet)
          raise Exception, 'File does not create a Fleet'
        end
      rescue Exception => e
        raise InvalidBlimpFileError, e.to_s
      end
      @fleet
    end
  end
end
