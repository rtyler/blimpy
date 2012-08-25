require 'spec_helper'

require 'blimpy/livery/puppet'

describe Blimpy::Livery::Puppet do
  context 'class methods' do
    subject { described_class }

    it { should respond_to :configure }
    describe '#configure' do
      it 'should return an instance of the Puppet livery' do
        result = subject.configure { |p| }
        expect(result).to be_instance_of described_class
      end

      it 'should raise a nice error if no configuration specified' do
        expect {
          subject.configure
        }.to raise_error(Blimpy::InvalidLiveryException)
      end

      it 'should yield an instance of the Puppet livery' do
        yielded = nil
        subject.configure { |p| yielded = p }
        expect(yielded).to be_instance_of described_class
      end
    end
  end

  it { should respond_to :module_path= }
  it { should respond_to :manifest_path= }
  it { should respond_to :options= }
end
