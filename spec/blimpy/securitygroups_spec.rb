require 'spec_helper'
require 'blimpy/securitygroups'

describe Blimpy::SecurityGroups do
    let(:fog) { mock('Fog object') }
    let(:ports) { [22, 8080] }

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
        subject.should_receive(:group_id).and_return('fake-id')
        name = subject.ensure_group(fog, ports)
        name.should == 'fake-id'
      end
    end

    context "for a group that doesn't exist" do
      it 'should create the group' do
        fog.stub_chain(:security_groups, :get).and_return(nil)
        subject.should_receive(:create_group).once
        subject.ensure_group(fog, ports)
      end
    end
  end

  describe '#create_group' do
    let(:group) { mock('Fog SecurityGroup') }
    it 'should authorize the port ranges for every port' do
      fog.stub_chain(:security_groups, :create).and_return(group)
      group.should_receive(:authorize_port_range).with(22..22)
      group.should_receive(:authorize_port_range).with(8080..8080)
      subject.create_group(fog, ports)
    end
  end
end
