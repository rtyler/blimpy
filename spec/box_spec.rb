require 'spec_helper'

describe Blimpy::Box do
  describe '#image_id' do
    it 'should be the Ubuntu 10.04 AMI ID by default' do
      subject.image_id.should == 'ami-349b495d'
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
end
