require 'spec_helper'
require 'blimpy/boxes/openstack'

describe Blimpy::Boxes::OpenStack do
  describe '#image_id' do
    it 'should be nil by default' do
      subject.image_id.should be_nil
    end
  end

  describe '#allowed_regions' do
    it 'should be nil by default' do
      subject.allowed_regions.should be_nil
    end
  end

  describe '#region=' do
    it 'should not raise an InvalidRegionError if no allowed_regions exist' do
      subject.stub(:allowed_regions).and_return(nil)
      subject.region = :elbonia
      subject.region.should == :elbonia
    end
  end
end
