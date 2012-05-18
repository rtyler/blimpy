require 'spec_helper'

describe Blimpy::Engine do
  describe '#load_file' do
    context 'no contents' do
      let(:content) { '' }

      it 'should raise InvalidBlimpFileError' do
        expect {
          subject.load_file(content)
        }.to raise_error(Blimpy::InvalidBlimpFileError)
      end

    end

    context 'invalid content' do
      let(:content) do
        """
          this is totally invalid Ruby
        """
      end

      it 'should raise InvalidBlimpFileError' do
        expect {
          subject.load_file(content)
        }.to raise_error(Blimpy::InvalidBlimpFileError)
      end
    end

    context 'valid content' do
      let(:content) do
        """
          Blimpy.fleet do |fleet|
            fleet.add(:aws) do |ship|
              ship.image_id = 'ami-349b495d'
              ship.livery = 'rails'
              ship.group = 'Simple'
              ship.region = 'us-west-1'
              ship.name = 'Rails App Server'
            end
          end
        """
      end

      it 'should create the appropriate Fleet object' do
        result = subject.load_file(content)
        result.should be_instance_of Blimpy::Fleet
        result.ships.should be_instance_of Array
        result.ships.size.should == 1

        ship = result.ships.first
        ship.group.should == 'Simple'
        ship.name.should == 'Rails App Server'
      end
    end
  end
end
