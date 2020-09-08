require 'spec_helper'

describe Puppet::Type.type(:sensu_agent_entity_config).provider(:sensu_api) do
  let(:provider) { described_class }
  let(:resource) { Puppet::Type.type(:sensu_agent_entity_config).new({name: 'subscriptions', value: 'test', entity: 'agent'}) }
  let(:data) { JSON.parse(my_fixture_read('entity_list.json')) }

  before(:each) do
    allow(provider).to receive(:namespaces).and_return(['default'])
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:api_request).with('entities', nil, {namespace: 'default', password: nil, url: nil, username: "puppet-agent_entity_config"}).and_return(data)
      expect(provider.instances.length).to eq(11)
    end

    it 'should return the resource for a entity' do
      allow(provider).to receive(:api_request).with('entities', nil, {namespace: 'default', password: nil, url: nil, username: "puppet-agent_entity_config"}).and_return(data)
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('subscriptions value entity:sensu-backend.example.com on sensu-backend.example.com in default')
    end
  end

  describe 'create' do
    it 'should create' do
      allow(resource.provider).to receive(:get_entity).with('agent', 'default', {:password=>nil, :url=>nil, :username=>"puppet-agent_entity_config"}).and_return(data[0])
      expect(resource.provider).to receive(:api_request)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update' do
      allow(resource.provider).to receive(:get_entity).with('agent', 'default', {:password=>nil, :url=>nil, :username=>"puppet-agent_entity_config"}).and_return(data[0])
      expect(resource.provider).to receive(:api_request)
      resource.provider.value = 'foo'
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a entity' do
      allow(resource.provider).to receive(:get_entity).with('agent', 'default', {password: nil, url: nil, username: "puppet-agent_entity_config"}).and_return(data[0])
      expect(resource.provider).to receive(:api_request)
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

