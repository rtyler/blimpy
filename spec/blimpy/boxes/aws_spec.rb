require 'spec_helper'
require 'blimpy/boxes/aws'

describe Blimpy::Boxes::AWS do
  describe '#image_id' do
    it 'should be the Ubuntu 10.04 AMI ID by default' do
      subject.image_id.should == Blimpy::Boxes::AWS::DEFAULT_IMAGE_ID
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

    describe '#from_instance_id' do
      let(:fog) { double('Fog::Compute') }
      before :each do
        fog.stub_chain(:servers, :get).and_return(server)
        Fog::Compute.should_receive(:new).and_return(fog)
      end

      it 'should create a new Box instance' do
        result = Blimpy::Boxes::AWS.from_instance_id('someid', {})
        result.should be_instance_of Blimpy::Boxes::AWS
      end
    end
  end

end
