
require 'rubygems'
require 'fog'

module Blimpy
  class Engine
    def load_file(file_content)
      raise InvalidBlimpFileError
    end
  end
end
