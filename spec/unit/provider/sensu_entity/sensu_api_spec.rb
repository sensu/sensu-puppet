require 'spec_helper'

describe Puppet::Type.type(:sensu_entity).provider(:sensu_api) do
  let(:provider) { described_class }
  let(:resource) { Puppet::Type.type(:sensu_entity).new({name: 'test', provider: 'sensu_api'}) }

  before(:each) do
    allow(provider).to receive(:namespaces).and_return(['default'])
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:api_request).with('entities', nil, {namespace: 'default'}).and_return(JSON.parse(my_fixture_read('entity_list.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a entity' do
      allow(provider).to receive(:api_request).with('entities', nil, {namespace: 'default'}).and_return(JSON.parse(my_fixture_read('entity_list.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('sensu-backend.example.com in default')
    end
  end

  describe 'create' do
    it 'should create a entity' do
      resource[:entity_class] = 'proxy'
      expected_spec = {
        :entity_class => 'proxy',
        :deregister => false,
        :metadata => {
          :name => 'test',
          :namespace => 'default',
        }
      }
      expect(resource.provider).to receive(:api_request).with('entities', expected_spec, {namespace: 'default', method: 'post'})
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a entity labels' do
      expected_spec = {
        :deregister => false,
        :metadata => {
          :name => 'test',
          :namespace => 'default',
          :labels => {'foo' => 'bar'},
        }
      }
      expect(resource.provider).to receive(:api_request).with('entities/test', expected_spec, {namespace: 'default', method: 'put'})
      resource.provider.labels = {'foo' => 'bar'}
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a entity' do
      expect(resource.provider).to receive(:api_request).with('entities/test', nil, {namespace: 'default', method: 'delete'})
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

