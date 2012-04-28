require 'spec_helper'

describe Blimpy::Fleet do
  describe '#hosts' do
    it 'should be an Array' do
      subject.hosts.should be_instance_of Array
      subject.hosts.size.should == 0
    end
  end

  describe '#add' do
    it 'should return false if no Box was properly added' do
      subject.add.should == false
    end

    it 'should pass a Box instance to the block' do
      invoked_block = false
      subject.add do |box|
        invoked_block = true
        box.should be_instance_of Blimpy::Box
      end
      invoked_block.should be true
    end

    context 'with a block' do
      before :each do
        subject.add do |b|
          @box = b
        end
      end

      it 'should add the box the fleet' do
        @box.should_not be nil
        subject.hosts.should include(@box)
      end
    end
  end

  describe '#save!' do
    let(:manifest) { 'fake-manifest' }
    let(:manifest_file) do
      fd = mock('Manifest File Descriptor')
      fd
    end

    before :each do
      subject.should_receive(:state_file).and_return(manifest)
    end

    it 'should save the fleet id' do
      fleet_id = 1337
      subject.should_receive(:id).and_return(fleet_id)
      File.should_receive(:open).with(manifest, 'w').and_yield(manifest_file)
      manifest_file.should_receive(:write).with("id=#{fleet_id}\n")
      subject.save!
    end
  end

  describe '#state_file' do
    it 'should return a file named manifest' do
      subject.should_receive(:state_folder).and_return('fake-state-folder')
      subject.state_file.should == 'fake-state-folder/manifest'
    end
  end

  context 'group operations' do
    let(:members) do
      members = []
      members << [0xdeadbeef, {}]
      members
    end
    let(:box) do
      box = double('Blimpy::Box')
      box.stub(:stop)
      box.stub(:destroy)
      box.stub(:wait_for_state)
      box
    end

    before :each do
      Blimpy::Box.should_receive(:from_instance_id).with(0xdeadbeef, {}).and_return(box)
      subject.should_receive(:members).and_return(members)
      # Stub out output methods, this will keep our output clean in RSpec
      subject.stub(:print)
      subject.stub(:puts)
    end

    describe '#stop' do
      it 'should run stop' do
        subject.stop
      end
    end

    describe '#destroy' do
      it 'should run destroy' do
        subject.destroy
      end
    end

    describe '#start' do
      it 'should invoke resume' do
        box.should_receive(:resume)
        subject.start
      end
    end
  end
end
