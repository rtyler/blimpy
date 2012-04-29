require 'rubygems'
require 'zlib'
require 'archive/tar/minitar'

module Blimpy
  class Livery
    def self.tarball_directory(directory)
      if directory.nil? || !(File.directory? directory)
        raise ArgumentError, "The argument '#{directory}' doesn't appear to be a directory"
      end

      directory = File.expand_path(directory)
      short_name = File.basename(directory)

      Dir.chdir(File.expand_path(directory  + '/../')) do
        self.gzip_for_directory(short_name, '/tmp') do |tgz|
          Archive::Tar::Minitar.pack(short_name, tgz)
        end
      end
    end

    private

    def self.gzip_for_directory(directory, root)
      filename = File.join(root, "#{directory}.tar.gz")
      yield Zlib::GzipWriter.new(File.open(filename, 'wb'))
      filename
    end

  end
end
