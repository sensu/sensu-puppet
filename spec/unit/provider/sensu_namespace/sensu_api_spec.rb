require 'spec_helper'

describe Puppet::Type.type(:sensu_namespace).provider(:sensu_api) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_namespace) }
  let(:resource) { type.new({:name => 'test', :provider => 'sensu_api' }) }

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:api_request).with('namespaces').and_return(JSON.parse(my_fixture_read('namespace_list.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a namespace' do
      allow(provider).to receive(:api_request).with('namespaces').and_return(JSON.parse(my_fixture_read('namespace_list.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('default')
    end
  end

  describe 'create' do
    it 'should create a namespace' do
      expected_spec = {
        :name => 'test',
      }
      expect(resource.provider).to receive(:api_request).with('namespaces', expected_spec, {:method => 'post'})
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'destroy' do
    it 'should delete a namespace' do
      expect(resource.provider).to receive(:api_request).with('namespaces/test', nil, {:method => 'delete'})
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

