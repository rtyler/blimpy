require 'spec_helper'
require 'blimpy/helpers/state'

describe Blimpy::Helpers::State do
  include Blimpy::Helpers::State

  describe '#state_folder' do
    it 'should be .blimpy.d in the working directory' do
      pwd = '/fake-pwd'
      Dir.should_receive(:pwd).and_return(pwd)
      state_folder.should == "#{pwd}/.blimpy.d"
    end
  end

  describe '#state_file' do
    it 'should raise an error since it must be defined by consumer classes' do
      expect {
        state_file
      }.to raise_error(NotImplementedError)
    end
  end

  describe '#ensure_state_folder' do
    it 'should make the dir if it doesn\'t exist' do
      File.should_receive(:exist?).and_return(false)
      Dir.should_receive(:mkdir)
      ensure_state_folder
    end

    it 'should not make the dir if it exists' do
      File.should_receive(:exist?).and_return(true)
      Dir.should_receive(:mkdir).never
      ensure_state_folder
    end
  end
end


