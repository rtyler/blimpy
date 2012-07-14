require 'spec_helper'
require 'blimpy/boxes/openstack'

shared_context 'valid floating_ip' do
  let(:floating) do
    floating = double('FloatingIp')
    floating.stub(:address).and_return('127.0.0.1')
    floating.stub(:id).and_return(7)
    floating
  end
  before :each do
    subject.stub(:floating_ip).and_return(floating)
  end
end

describe Blimpy::Boxes::OpenStack do
  describe '#image_id' do
    it 'should be nil by default' do
      subject.image_id.should be_nil
    end
  end

  describe '#username' do
    it 'should be "ubuntu" by default' do
      subject.username.should == 'ubuntu'
    end
  end

  describe '#flavor' do
    it 'should be "m1.tiny" by default' do
      subject.flavor.should == 'm1.tiny'
    end
  end

  describe '#group' do
    it 'should be "default" by default' do
      subject.group.should == 'default'
    end
  end

  describe '#allowed_regions' do
    it 'should be nil by default' do
      subject.allowed_regions.should be_nil
    end
  end

  describe '#region=' do
    it 'should not raise an InvalidRegionError if no allowed_regions exist' do
      subject.stub(:allowed_regions).and_return(nil)
      subject.region = :elbonia
      subject.region.should == :elbonia
    end
  end

  describe '#ports=' do
    it 'should be disabled currently' do
      expect {
        subject.ports = [22, 8080]
      }.to raise_error(Blimpy::UnsupportedFeatureException)
    end
  end

  describe '#validate!' do
    it 'should raise a validation error if there isn\'t a region' do
      subject.region = nil
      expect {
        subject.validate!
      }.to raise_error(Blimpy::BoxValidationError)
    end
  end

  context 'with mocked flavors' do
    let(:fog) { double('Fog') }
    let(:flavors) do
      flavor = double('Fog::Compute::OpenStack::Flavor')
      flavor.stub(:id).and_return('1')
      flavor.stub(:name).and_return('m1.tiny')
      [flavor]
    end

    before :each do
      fog.should_receive(:flavors).and_return(flavors)
      subject.should_receive(:fog).and_return(fog)
    end

    describe '#flavors' do
      it 'should pull the list of flavors from Fog' do
        subject.flavors.should == flavors
      end
    end

    describe '#flavor_id' do
      it 'should filter out the right flavor' do
        subject.flavor_id('m1.tiny').should == '1'
      end

      it 'should return nil if the flavor doesn\'t exist' do
        subject.flavor_id('invalid').should be_nil
      end
    end

    describe '#validate!' do
      it 'should raise a validation error with an invalid flavor' do
        subject.flavor = 'invalid'
        subject.region = 'test'
        expect {
          subject.validate!
        }.to raise_error(Blimpy::BoxValidationError)
      end

    end

  end

  describe '#prestart' do
    it 'should allocate an IP' do
      subject.should_receive(:allocate_ip)
      subject.prestart
    end
  end

  describe '#allocate_ip' do
    let(:fog) { double('Fog') }

    before :each do
      subject.stub(:fog).and_return(fog)
    end

    context 'with a bad response' do
      let(:response) do
        response = double('Excon::Response')
        response.stub(:status).and_return(500)
        response
      end

      it 'should raise an error if we cannot allocate the IP' do
        fog.should_receive(:allocate_address).and_return(response)
        expect {
          subject.allocate_ip
        }.to raise_error(Blimpy::UnknownError)
      end
    end

    context 'with a good response' do
      let(:response) do
        response = double('Excon::Response')
        response.stub(:status).and_return(200)
        response.stub(:body).and_return({"floating_ip"=>
            {"instance_id"=>nil,
            "ip"=>"10.38.12.109",
            "fixed_ip"=>nil,
            "id"=>109,
            "pool"=>"nova"}})
        response
      end

      it 'should allocate and store the floating IP info' do
        fog.should_receive(:allocate_address).and_return(response)

        subject.allocate_ip
        subject.floating_ip.address.should == '10.38.12.109'
        subject.floating_ip.id.should == 109
      end
    end
  end

  describe '#associate_ip' do
    let(:fog) { double('Fog') }
    include_context 'valid floating_ip'
    let(:server) do
      server = double('Fog::Compute::Server')
      server.stub(:id).and_return(server_id)
      server
    end
    let(:server_id) { 'fake-id' }

    subject { described_class.new(server) }

    before :each do
      subject.stub(:fog).and_return(fog)
    end

    it 'should raise an exception if a floating IP hasn\'t been created' do
      subject.stub(:floating_ip).and_return(nil)
      expect {
        subject.associate_ip
      }.to raise_error(Blimpy::UnknownError)
    end

    context 'with a good response' do
      let(:response) do
        response = double('Excon::Response')
        response.stub(:status).and_return(202)
        response
      end

      it 'should associate the right IP to the right instance ID' do
        fog.should_receive(:associate_address).with(server_id, floating.address).and_return(response)
        subject.associate_ip
      end
    end

    context 'with a bad response' do
      let(:response) do
        response = double('Excon::Response')
        response.stub(:status).and_return(500)
        response
      end

      it 'should raise an error' do
        subject.stub(:floating_ip).and_return(floating)
        fog.should_receive(:associate_address).with(server_id, floating.address).and_return(response)
        expect {
          subject.associate_ip
        }.to raise_error(Blimpy::UnknownError)
      end
    end
  end

  describe '#predestroy' do
    context 'if the server has a floating IP' do
      include_context 'valid floating_ip'

      it 'should disasscoaite it' do
        subject.should_receive(:disassociate_ip)
        subject.predestroy
      end
    end

    context 'if the server has no floating IP' do
      it 'should not try to disassociate it' do
        subject.should_receive(:disassociate_ip).never
        subject.predestroy
      end
    end
  end

  describe '#postdestroy' do
    context 'if the server has a floating IP' do
      include_context 'valid floating_ip'

      it 'should deallocate the IP' do
        subject.should_receive(:deallocate_ip)
        subject.postdestroy
      end
    end

    context 'if the server has no floating IP' do
      it 'should not try to deallocate the IP' do
        subject.should_receive(:deallocate_ip).never
        subject.postdestroy
      end
    end
  end

  describe '#disassociate_ip' do
    let(:fog) { double('Fog') }
    include_context 'valid floating_ip'
    let(:server) do
      server = double('Fog::Compute::Server')
      server.stub(:id).and_return(server_id)
      server
    end
    let(:server_id) { 'fake-id' }

    subject { described_class.new(server) }

    before :each do
      subject.stub(:fog).and_return(fog)
    end

    it 'should disassociate the right IP to the right instance ID' do
      fog.should_receive(:disassociate_address).with(server_id, floating.address)
      subject.disassociate_ip
    end
  end

  describe '#deallocate_ip' do
    let(:fog) { double('Fog') }
    include_context 'valid floating_ip'

    before :each do
      subject.stub(:fog).and_return(fog)
    end

    context 'with a good response' do
      let(:response) do
        response = double('Excon::Response')
        response.stub(:status).and_return(202)
        response
      end

      it 'should release the right IP by floating_ip ID' do
        fog.should_receive(:release_address).with(floating.id).and_return(response)
        subject.deallocate_ip
      end
    end
  end
end

describe Blimpy::Boxes::OpenStack::FloatingIp do
  subject do
    described_class.new('127.0.0.1', 1)
  end

  it { should respond_to(:to_yaml) }
end
