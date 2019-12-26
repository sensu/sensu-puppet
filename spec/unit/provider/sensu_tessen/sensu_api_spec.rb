require 'spec_helper'

describe Puppet::Type.type(:sensu_tessen).provider(:sensu_api) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_tessen) }
  let(:resource) do
    type.new({
      :name => 'test',
      :ensure => 'present',
    })
  end

  before(:each) do
    allow(provider).to receive(:namespaces).and_return(['default'])
  end

  describe 'state' do
    it 'should be present' do
      allow(provider).to receive(:api_request).with('tessen').and_return({"opt_out" => false})
      expect(resource.provider.state).to eq(:present)
    end

    it 'should be absent' do
      allow(provider).to receive(:api_request).with('tessen').and_return({"opt_out" => true})
      expect(resource.provider.state).to eq(:absent)
    end
  end

  describe 'create' do
    it 'does not opt out' do
      expect(resource.provider).to receive(:api_request).with('tessen', {"opt_out" => false}, {method: 'put'})
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'destroy' do
    it 'opts out' do
      expect(resource.provider).to receive(:api_request).with('tessen', {"opt_out" => true}, {method: 'put'})
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

