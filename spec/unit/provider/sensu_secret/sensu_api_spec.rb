require 'spec_helper'

describe Puppet::Type.type(:sensu_secret).provider(:sensu_api) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_secret) }
  let(:config) do
    {
      :name => 'test',
      :id => 'test',
      :secrets_provider => 'env',
      :provider => 'sensu_api',
    }
  end
  let(:resource) do
    type.new(config)
  end

  describe 'self.instances' do
    before(:each) do
      allow(provider).to receive(:namespaces).and_return(['default'])
    end

    let(:opts) do
      {:namespace => 'default', :api_group => 'enterprise/secrets', :api_version => 'v1', :failonfail => false}
    end
    it 'should create instances' do
      allow(provider).to receive(:api_request).with('secrets', nil, opts).and_return(JSON.parse(my_fixture_read('list.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a auth' do
      allow(provider).to receive(:api_request).with('secrets', nil, opts).and_return(JSON.parse(my_fixture_read('list.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('sensu-ansible in default')
    end
  end

  describe 'create' do
    it 'should create an auth' do
      expected_spec = {
        :spec => {
          :id => 'test',
          :provider => 'env',
        },
        :metadata => {
          :name => 'test',
          :namespace => 'default',
        },
        :api_version => 'secrets/v1',
        :type => 'Secret',
      }
      expect(resource.provider).to receive(:api_request).with('secrets/test', expected_spec, {:namespace => 'default', :api_group => 'enterprise/secrets', :api_version => 'v1', :method => 'put'})
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update an auth config' do
      expected_spec = {
        :spec => {
          :id => 'tests',
          :provider => 'env',
        },
        :metadata => {
          :name => 'test',
          :namespace => 'default'
        },
        :api_version => 'secrets/v1',
        :type => 'Secret',
      }
      expect(resource.provider).to receive(:api_request).with('secrets/test', expected_spec, {:namespace => 'default', :api_group => 'enterprise/secrets', :api_version => 'v1', :method => 'put'})
      resource.provider.id = 'tests'
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete an auth' do
      expect(resource.provider).to receive(:api_request).with('secrets/test', nil, {:namespace => 'default', :api_group => 'enterprise/secrets', :api_version => 'v1', :method => 'delete'})
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

