require 'spec_helper'

describe Blimpy::Box do
  describe '#image_id' do
    it 'should be the Ubuntu 10.04 AMI ID by default' do
      subject.image_id.should == Blimpy::Box::DEFAULT_IMAGE_ID
    end
  end

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

  describe '#allowed_regions' do
    it 'should be an Array' do
      subject.allowed_regions.should be_instance_of Array
    end
    it 'should not be empty' do
      subject.allowed_regions.should_not be_empty
    end
  end

  describe '#region' do
    it 'should return the default region' do
      subject.region.should == 'us-west-2'
    end
  end

  describe '#region=' do
    it 'should raise an InvalidRegionError if the region is not allowed' do
      expect {
        subject.region = :elbonia
      }.to raise_error(Blimpy::InvalidRegionError)
    end

    it 'should change the value of @region' do
      subject.region = 'us-east-1'
      subject.region.should == 'us-east-1'
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
      # Fog::Compute[:aws] will return a *new* instance of
      # Fog::Compute::Aws::Real every time (apparently) it is invoked
      Fog::Compute::AWS::Real.any_instance.should_receive(:security_groups).and_return(groups)
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

    describe '#from_instance_id' do
      let(:fog) { double('Fog::Compute') }
      before :each do
        fog.stub_chain(:servers, :get).and_return(server)
        Fog::Compute.should_receive(:new).and_return(fog)
      end

      it 'should create a new Box instance' do
        result = Blimpy::Box.from_instance_id('someid', {})
        result.should be_instance_of Blimpy::Box
      end

    end
  end
end
