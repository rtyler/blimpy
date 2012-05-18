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
    it 'should raise a NotImplementedError, since this should be defined by subclasses' do
      expect {
        subject.validate!
      }.to raise_error(NotImplementedError)
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
