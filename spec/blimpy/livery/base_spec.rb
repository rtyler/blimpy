require 'spec_helper'
require 'blimpy/livery/base'


describe Blimpy::Livery::Base do
  describe '#rsync_excludes' do
    it { subject.rsync_excludes.should be_instance_of Array }
  end

  describe '#rsync_command' do
    subject { described_class.new.rsync_command }

    it { expect(subject.first).to eql('rsync') }
    it { should include('--exclude=.git') }
  end

  describe '#livery_root' do
    it { expect(subject.livery_root).to eql(Dir.pwd) }
  end

end
