require 'rubygems'
require 'aruba/cucumber'
require 'fileutils'
require 'ruby-debug'
require 'temp_dir'


# Pull in my gem working directory bin directory
ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"

$:.unshift(File.expand_path(File.dirname(__FILE__) + "/../../lib"))
require 'blimpy'
require 'blimpy/livery'

module Blimpy
  module Cucumber
    def create_blimpfile(string)
      path = File.join(@tempdir, 'Blimpfile')
      File.open(path, 'w') do |f|
        f.write(string)
      end
    end
  end
end

World(Blimpy::Cucumber)
