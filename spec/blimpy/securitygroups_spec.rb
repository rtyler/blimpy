require 'spec_helper'
require 'blimpy/securitygroups'

describe Blimpy::SecurityGroups do
  describe '#group_id' do
    it 'should return nil for an empty port Array' do
      subject.group_id([]).should be_nil
    end

    context 'with a known ID' do
      let(:known_id) { 3548764514 }

      it 'should generate the right string for [1, 2]' do
        subject.group_id([1, 2]).should == "Blimpy-#{known_id}"
      end

      it 'should generate the identical string for [1, 2, 1]' do
        subject.group_id([1, 2, 1]).should == "Blimpy-#{known_id}"
      end
    end
  end
end
