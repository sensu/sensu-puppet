require 'spec_helper'

describe Puppet::Type.type(:sensu_bonsai_asset).provider(:sensuctl) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_bonsai_asset) }
  let(:config) do
    { :name => 'sensu/sensu-pagerduty-handler' }
  end
  let(:resource) do
    type.new(config)
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:sensuctl_list).with('asset').and_return(JSON.parse(my_fixture_read('asset_list.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a asset' do
      allow(provider).to receive(:sensuctl_list).with('asset').and_return(JSON.parse(my_fixture_read('asset_list.json')))
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
      expected_cmd = ['asset','add','sensu/sensu-pagerduty-handler','--rename','sensu/sensu-pagerduty-handler','--namespace','default']
      expect(resource.provider).to receive(:sensuctl).with(expected_cmd)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
    it 'should create a bonsai_asset for latest' do
      config[:version] = 'latest'
      expected_cmd = ['asset','add','sensu/sensu-pagerduty-handler','--rename','sensu/sensu-pagerduty-handler','--namespace','default']
      expect(resource.provider).to receive(:sensuctl).with(expected_cmd)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
    it 'should create a bonsai_asset for a version' do
      config[:version] = '1.2.0'
      expected_cmd = ['asset','add','sensu/sensu-pagerduty-handler:1.2.0','--rename','sensu/sensu-pagerduty-handler','--namespace','default']
      expect(resource.provider).to receive(:sensuctl).with(expected_cmd)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should install latest bonsai asset' do
      expected_cmd = ['asset','add','sensu/sensu-pagerduty-handler','--rename','sensu/sensu-pagerduty-handler','--namespace','default']
      expect(resource.provider).to receive(:sensuctl).with(expected_cmd)
      resource.provider.version = 'latest'
      resource.provider.flush
    end
    it 'should install a version of bonsai asset' do
      expected_cmd = ['asset','add','sensu/sensu-pagerduty-handler:1.2.0','--rename','sensu/sensu-pagerduty-handler','--namespace','default']
      expect(resource.provider).to receive(:sensuctl).with(expected_cmd)
      resource.provider.version = '1.2.0'
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a asset' do
      expect(resource.provider).to receive(:sensuctl_delete).with('asset', 'sensu/sensu-pagerduty-handler', 'default')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

