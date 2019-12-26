require 'spec_helper'

describe Puppet::Type.type(:sensu_filter).provider(:sensu_api) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_filter) }
  let(:resource) do
    type.new({
      :name => 'test',
      :action => 'allow',
      :expressions => ["event.entity.labels.environment == 'production'"],
      :provider => 'sensu_api',
    })
  end

  before(:each) do
    allow(provider).to receive(:namespaces).and_return(['default'])
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:api_request).with('filters', nil, {:namespace => 'default'}).and_return(JSON.parse(my_fixture_read('filter_list.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a filter' do
      allow(provider).to receive(:api_request).with('filters', nil, {:namespace => 'default'}).and_return(JSON.parse(my_fixture_read('filter_list.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('production_filter in default')
    end
  end

  describe 'create' do
    it 'should create a filter' do
      expected_spec = {
        :action => :allow,
        :expressions => ["event.entity.labels.environment == 'production'"],
        :metadata => {
          :name => 'test',
          :namespace => 'default',
        },
      }
      expect(resource.provider).to receive(:api_request).with('filters', expected_spec, {:namespace => 'default', :method => 'post'})
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a filter action' do
      expected_spec = {
        :action => 'deny',
        :expressions => ["event.entity.labels.environment == 'production'"],
        :metadata => {
          :name => 'test',
          :namespace => 'default',
        },
      }
      expect(resource.provider).to receive(:api_request).with('filters/test', expected_spec, {:namespace => 'default', :method => 'put'})
      resource.provider.action = 'deny'
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a filter' do
      expect(resource.provider).to receive(:api_request).with('filters/test', nil, {:namespace => 'default', :method => 'delete'})
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

