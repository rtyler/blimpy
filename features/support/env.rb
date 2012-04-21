require 'aruba/cucumber'
require 'tempdir'

# Pull in my gem working directory bin directory
ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"

