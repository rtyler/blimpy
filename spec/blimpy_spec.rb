require 'spec_helper'

describe Blimpy do
  describe '#fleet' do
    it 'should create a new Fleet' do
      result = subject.fleet
      pending 'Requires Blimpy::Fleet to exist'
      result.should be_instance_of Blimpy::Fleet
    end
  end
end
