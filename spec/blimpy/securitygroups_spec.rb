require 'spec_helper'
require 'blimpy/securitygroups'

describe Blimpy::SecurityGroups do
    let(:fog) { mock('Fog object') }
    # Due to the implementation of the group_id method, [22,8140] can trigger
    # a failure case that is not triggered by [22,8080].
    # Zlib.crc32(Set.new(Set.new([22,8140])).inspect) != Zlib.crc32(Set.new([22,8140]).inspect), at least in ruby 1.8.7
    let(:ports) { [22, 8140 ] }
    let(:expected_group_name) { subject.group_id(ports) }

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

  describe '#ensure_group' do
    context 'for a group that exists' do
      it 'should bail and not try to create the group' do
        fog.stub_chain(:security_groups, :get).and_return(true)
        subject.should_receive(:create_group).never
        name = subject.ensure_group(fog, ports)
        name.should == expected_group_name
      end
    end

    context "for a group that doesn't exist" do
      let(:sec_groups) { mock('Fog Security Groups object') }
      let(:group) { mock('Fog SecurityGroup') }

      it 'should create the group' do
        fog.stub(:security_groups).and_return(sec_groups)
        sec_groups.should_receive(:get).with(expected_group_name).and_return(nil)
        sec_groups.should_receive(:create).and_return(group)
        group.stub(:authorize_port_range)
        name = subject.ensure_group(fog, ports)
        name.should == expected_group_name
      end
    end
  end

  describe '#create_group' do
    let(:group) { mock('Fog SecurityGroup') }
    it 'should authorize the port ranges for every port' do
      fog.stub_chain(:security_groups, :create).and_return(group)
      group.should_receive(:authorize_port_range).with(22..22)
      group.should_receive(:authorize_port_range).with(8140..8140)
      subject.create_group(fog, ports)
    end
  end
end
