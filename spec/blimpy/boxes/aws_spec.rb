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
    let (:fog) { mock('Fog::Compute::AWS') }

    before :each do
      subject.stub(:fog).and_return(fog)
    end

    it 'should raise if no region has been set' do
      expect {
        # This may be a silly test
        subject.instance_variable_set(:@region, nil)
        subject.validate!
      }.to raise_error(Blimpy::BoxValidationError)
    end

    context 'with invalid settings' do
      it 'should raise with a bad security group' do
        fog.stub_chain(:security_groups, :get).and_return(nil)
        expect {
          subject.validate!
        }.to raise_error(Blimpy::BoxValidationError)
      end
    end

    context 'with valid settings' do
      it 'should validate with a good security group' do
        fog.stub_chain(:security_groups, :get).with('MockedGroup').and_return(security_group)
        expect {
          subject.group = 'MockedGroup'
          subject.validate!
        }.not_to raise_error(Blimpy::BoxValidationError)
      end
    end
  end
end
