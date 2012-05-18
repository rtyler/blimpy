require 'spec_helper'

describe Blimpy::Box do

  describe '#livery' do
    it 'should be unset by default' do
      subject.livery.should be nil
    end
  end

  describe '#group' do
    it 'should be unset by default' do
      subject.group.should be nil
    end
  end

  describe '#name' do
    it 'should be "Unnamed Box" by default' do
      subject.name.should == 'Unnamed Box'
    end
  end

  describe '#validate!' do
    let(:security_group) do
      group = double('Fog::Compute::AWS::SecurityGroup')
      group.stub(:name).and_return('MockedGroup')
      group
    end
    let(:groups) { double('Fog::Compute::AWS::SecurityGroups') }

    before :each do
      Fog::Compute.stub_chain(:[], :security_groups).and_return(groups)
    end

    context 'with invalid settings' do
      it 'should raise with a bad security group' do
        groups.should_receive(:get).and_return(nil)
        expect {
          subject.validate!
        }.to raise_error(Blimpy::BoxValidationError)
      end
    end

    context 'with valid settings' do
      it 'should validate with a good security group' do
        groups.should_receive(:get).with('MockedGroup').and_return(security_group)
        expect {
          subject.group = 'MockedGroup'
          subject.validate!
        }.not_to raise_error(Blimpy::BoxValidationError)
      end
    end
  end

  context 'with a mocked server' do
    let(:server_id) { 'id-0xdeadbeef' }
    let(:server) do
      server = double('Fog::Compute::AWS::Server')
      server.stub(:id).and_return(server_id)
      server
    end

    describe '#start' do
      before :each do
        # Mocking out #create_host so we don't actually create EC2 instance
        Blimpy::Box.any_instance.should_receive(:create_host).and_return(server)
        Blimpy::Box.any_instance.should_receive(:ensure_state_folder).and_return(true)
      end

      it 'should create a state file' do
        subject.stub(:state_file).and_return('fake-state-file')
        File.should_receive(:open).with('fake-state-file', 'w')
        subject.start
      end
    end

    describe '#stop' do
      before :each do
        server.should_receive(:stop)
      end

      subject { Blimpy::Box.new(server) }

      it 'should stop the Box' do
        subject.stop
      end
    end

    describe '#destroy' do
      before :each do
        server.should_receive(:destroy)
      end
      subject { Blimpy::Box.new(server) }

      it 'should remove its state file' do
        subject.should_receive(:state_file).and_return('fake-state-file')
        File.should_receive(:unlink).with('fake-state-file')
        subject.destroy
      end
    end


    describe '#bootstrap_livery' do
      context 'with a livery of :cwd' do
        before :each do
          subject.livery = :cwd
        end

        it 'should tarball up the current directory' do
          Dir.should_receive(:pwd).and_return('mock-pwd')
          Blimpy::Livery.should_receive(:tarball_directory).with('mock-pwd').and_return('mock-pwd.tar.gz')
          subject.should_receive(:scp_file).with('mock-pwd.tar.gz')
          subject.should_receive(:ssh_into)
          subject.bootstrap_livery
        end
      end
    end
  end
end
