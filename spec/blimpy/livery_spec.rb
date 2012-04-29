require 'spec_helper'
require 'blimpy/livery'

describe Blimpy::Livery do
  context 'class methods' do
    describe '#tarball_directory' do
      subject { Blimpy::Livery } # No instantiating!
      it 'should raise an exception if the directory doesn\'t exist' do
        expect {
          subject.tarball_directory(nil)
        }.to raise_error(ArgumentError)

        expect {
          subject.tarball_directory('/tmp/never-gonna-give-you-up.lolz')
        }.to raise_error(ArgumentError)
      end
    end
  end
end
