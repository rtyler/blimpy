require 'spec_helper'
require 'blimpy/keys'

describe Blimpy::Keys do
  subject(:keys) { described_class }

  describe '#public_key' do
    context 'with no SSH keys' do
      it 'should raise a SSHKeyNotFoundError' do
        File.stub(:exists?).and_return(false)
        expect {
          keys.public_key
        }.to raise_error(Blimpy::SSHKeyNotFoundError)
      end
    end
  end

  describe '#key_name' do
    let(:username) { 'rspecguy' }
    before :each do
      ENV['USER'] = username
      Socket.should_receive(:gethostname).and_return(hostname)
    end

    context 'with a simple hostname' do
      let(:hostname) { 'rspec' }

      it 'should create the right key name' do
        expect(keys.key_name).to eql("Blimpy-#{username}-#{hostname}")
      end
    end

    context 'with a FQDN' do
      let(:hostname) { 'rspec.github.io' }

      it 'should create the right key name' do
        expect(keys.key_name).to eql("Blimpy-#{username}-rspec-github-io")
      end
    end
  end
end
