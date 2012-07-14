require 'spec_helper'
require 'blimpy/keys'

describe Blimpy::Keys do
  describe '#public_key' do
    context 'with no SSH keys' do
      it 'should raise a SSHKeyNotFoundError' do
        File.stub(:exists?).and_return(false)
        expect {
          subject.public_key
        }.to raise_error(Blimpy::SSHKeyNotFoundError)
      end
    end
  end

  describe '#key_name' do
    before :each do
      ENV['USER'] = 'tester'
    end

    it do
      hostname = 'rspec'
      Socket.should_receive(:gethostname).and_return(hostname)
      subject.key_name.should == "Blimpy-tester-#{hostname}"
    end
  end
end
