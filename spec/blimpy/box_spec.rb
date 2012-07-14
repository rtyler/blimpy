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

  describe '#create_host' do
    it 'should raise a NotImplementedError' do
      # lol private
      expect {
        subject.send(:create_host)
      }.to raise_error(NotImplementedError)
    end
  end

  describe '#fog' do
    it 'should raise NotImplementedError' do
      expect {
        subject.fog.should be_nil
      }.to raise_error(NotImplementedError)
    end
  end

  describe '#with_data' do
    context 'with valid data' do
      let(:data) do
        {'type' => 'AWS',
         'name' => 'Fakey',
         'region' => 'us-west-2',
         'dns' => 'ec2-50-112-24-134.us-west-2.compute.amazonaws.com',
         'internal_dns' => 'ip-10-252-73-124.us-west-2.compute.internal'}
      end
      let(:ship_id) { 'i-deadbeef' }

      before :each do
        subject.with_data(ship_id, data)
      end

      it 'should set the dns_name' do
        subject.dns.should == data['dns']
      end

      it 'should set the region' do
        subject.region.should == data['region']
      end
    end
  end

  context 'with a mocked server' do
    let(:server_id) { 'id-0xdeadbeef' }
    let(:server) do
      server = double('Fog::Compute::AWS::Server')
      server.stub(:id).and_return(server_id)
      server.stub(:dns_name).and_return('test')
      server.stub(:private_dns_name).and_return('test')
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

    describe '#from_instance_id' do
      let(:fog) { double('Fog::Compute') }

      it 'should fail if no "type" exists' do
        result = Blimpy::Box.from_instance_id('someid', {})
        result.should be_nil
      end

      it 'should fail if the "type" is not a defined Box class' do
        result = Blimpy::Box.from_instance_id('someid', {:type => 'MAGIC'})
        result.should be_nil
      end

      context 'with an AWS box type' do
        before :each do
          fog.stub_chain(:servers, :get).and_return(server)
          Fog::Compute.should_receive(:new).and_return(fog)
        end

        it 'should create a new AWS Box instance' do
          result = Blimpy::Box.from_instance_id('someid', {:type => 'AWS'})
          result.should be_instance_of Blimpy::Boxes::AWS
        end
      end
    end
  end
end
