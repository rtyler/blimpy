require 'spec_helper'

describe Blimpy do
  describe '#fleet' do
    context 'without a block' do
      it 'should not create a new Fleet' do
        Blimpy::Fleet.should_receive(:new).never
        subject.fleet
      end
    end

    context 'with a block' do
      it 'should create a new Fleet' do
        result = subject.fleet do |f|
        end
        result.should be_instance_of Blimpy::Fleet
      end

      it 'should invoke the block with a Fleet' do
        invoked_block = false
        subject.fleet do |f|
          invoked_block = true
        end
        invoked_block.should be true
      end
    end
  end
end
