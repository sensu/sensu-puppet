require 'spec_helper'

describe Puppet::Type.type(:sensu_cluster_federation_member).provider(:sensu_api) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_cluster_federation_member) }
  let(:resource) do
    type.new({
      :name => 'test',
      :api_url => 'https://10.0.0.3:8080',
      :cluster => 'test',
      :provider => 'sensu_api',
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      opts = {
        :api_group => 'enterprise/federation',
        :api_version => 'v1',
      }
      allow(provider).to receive(:api_request).with('clusters', nil, opts).and_return(JSON.parse(my_fixture_read('get.json')))
      expect(provider.instances.length).to eq(2)
    end

    it 'should return the resource for a check' do
      opts = {
        :api_group => 'enterprise/federation',
        :api_version => 'v1',
      }
      allow(provider).to receive(:api_request).with('clusters', nil, opts).and_return(JSON.parse(my_fixture_read('get.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('https://10.0.0.1:8080 in test')
    end
  end

  describe 'create' do
    it 'should create a federated cluster' do
      expected_spec = {
        :spec => {
          :api_urls => ['https://10.0.0.1:8080','https://10.0.0.2:8080','https://10.0.0.3:8080'],
        },
        :metadata => { :name => 'test' },
        :api_version => 'federation/v1',
        :type => 'Cluster',
      }
      get_opts = {
        :api_group => 'enterprise/federation',
        :api_version => 'v1',
        :failonfail => false,
      }
      opts = {
        :api_group => 'enterprise/federation',
        :api_version => 'v1',
        :method => 'put',
      }
      allow(resource.provider).to receive(:api_request).with('clusters/test', nil, get_opts).and_return(JSON.parse(my_fixture_read('get_cluster.json')))
      expect(resource.provider).to receive(:api_request).with('clusters/test', expected_spec, opts)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'destroy' do
    it 'should delete a check' do
      expected_spec = {
        :spec => {
          :api_urls => ['https://10.0.0.1:8080','https://10.0.0.2:8080'],
        },
        :metadata => { :name => 'test' },
        :api_version => 'federation/v1',
        :type => 'Cluster',
      }
      get_opts = {
        :api_group => 'enterprise/federation',
        :api_version => 'v1',
        :failonfail => false,
      }
      opts = {
        :api_group => 'enterprise/federation',
        :api_version => 'v1',
        :method => 'put',
      }
      allow(resource.provider).to receive(:api_request).with('clusters/test', nil, get_opts).and_return(JSON.parse(my_fixture_read('get_cluster.json')))
      expect(resource.provider).to receive(:api_request).with('clusters/test', expected_spec, opts)
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

