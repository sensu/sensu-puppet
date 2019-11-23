require 'spec_helper'

describe Puppet::Type.type(:sensu_hook).provider(:sensu_api) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_hook) }
  let(:resource) do
    type.new({
      :name => 'test',
      :command => 'test',
      :provider => 'sensu_api',
    })
  end

  before(:each) do
    allow(provider).to receive(:namespaces).and_return(['default'])
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:api_request).with('hooks', nil, {:namespace => 'default'}).and_return(JSON.parse(my_fixture_read('hook_list.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a hook' do
      allow(provider).to receive(:api_request).with('hooks', nil, {:namespace => 'default'}).and_return(JSON.parse(my_fixture_read('hook_list.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('process_tree in default')
    end
  end

  describe 'create' do
    it 'should create a hook' do
      expected_spec = {
        :command => 'test',
        :timeout => 60,
        :stdin => false,
        :metadata => {
          :name => 'test',
          :namespace => 'default',
        },
      }
      expect(resource.provider).to receive(:api_request).with('hooks', expected_spec, {:namespace => 'default', :method => 'post'})
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a hook timeout' do
      expected_spec = {
        :command => 'test',
        :timeout => 120,
        :stdin => false,
        :metadata => {
          :name => 'test',
          :namespace => 'default',
        },
      }
      expect(resource.provider).to receive(:api_request).with('hooks/test', expected_spec, {:namespace => 'default', :method => 'put'})
      resource.provider.timeout = 120
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a hook' do
      expect(resource.provider).to receive(:api_request).with('hooks/test', nil, {:namespace => 'default', :method => 'delete'})
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

