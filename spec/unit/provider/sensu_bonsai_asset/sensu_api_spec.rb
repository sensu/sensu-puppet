require 'spec_helper'

describe Puppet::Type.type(:sensu_bonsai_asset).provider(:sensu_api) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_bonsai_asset) }
  let(:config) do
    {
      :name => 'sensu/sensu-pagerduty-handler',
      :provider => 'sensu_api',
    }
  end
  let(:resource) do
    type.new(config)
  end

  before(:each) do
    allow(provider).to receive(:namespaces).and_return(['default'])
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:api_request).with('assets', nil, {namespace: 'default'}).and_return(JSON.parse(my_fixture_read('asset_list.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a asset' do
      allow(provider).to receive(:api_request).with('assets', nil, {namespace: 'default'}).and_return(JSON.parse(my_fixture_read('asset_list.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('sensu/sensu-pagerduty-handler in default')
    end
  end

  describe 'self.latest_version' do
    it 'should return latest version' do
      allow(Puppet::Provider::SensuAPI).to receive(:get_bonsai_asset).with('sensu/sensu-pagerduty-handler').and_return(JSON.parse(my_fixture_read('bonsai_asset.json')))
      latest_version = provider.latest_version('sensu', 'sensu-pagerduty-handler')
      expect(latest_version).to eq('1.2.0')
    end
  end

  describe 'create' do
    it 'should create a bonsai_asset' do
      expect(resource.provider).to receive(:manage_asset).with(nil, false)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should install latest bonsai asset' do
      expect(resource.provider).to receive(:manage_asset).with('latest', true)
      resource.provider.version = 'latest'
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a asset' do
      expect(resource.provider).to receive(:api_request).with('assets/sensu%2Fsensu-pagerduty-handler', nil, {namespace: 'default', method: 'delete'})
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

