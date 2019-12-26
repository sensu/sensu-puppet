require 'spec_helper'

describe Puppet::Type.type(:sensu_cluster_federation).provider(:sensu_api) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_cluster_federation) }
  let(:resource) do
    type.new({
      :name => 'test',
      :api_urls => ['http://10.0.0.1:8080','http://10.0.0.2:8080'],
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
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a check' do
      opts = {
        :api_group => 'enterprise/federation',
        :api_version => 'v1',
      }
      allow(provider).to receive(:api_request).with('clusters', nil, opts).and_return(JSON.parse(my_fixture_read('get.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('test')
    end
  end

  describe 'create' do
    it 'should create a federated cluster' do
      expected_spec = {
        :spec => {
          :api_urls => ['http://10.0.0.1:8080','http://10.0.0.2:8080'],
        },
        :metadata => { :name => 'test' },
        :api_version => 'federation/v1',
        :type => 'Cluster',
      }
      opts = {
        :api_group => 'enterprise/federation',
        :api_version => 'v1',
        :method => 'put',
      }
      expect(resource.provider).to receive(:api_request).with('clusters/test', expected_spec, opts)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a check proxy_requests' do
      expected_spec = {
        :spec => {
          :api_urls => ['http://10.0.0.1:8080','http://10.0.0.2:8080','http://10.0.0.3:8080'],
        },
        :metadata => { :name => 'test' },
        :api_version => 'federation/v1',
        :type => 'Cluster',
      }
      opts = {
        :api_group => 'enterprise/federation',
        :api_version => 'v1',
        :method => 'put',
      }
      expect(resource.provider).to receive(:api_request).with('clusters/test', expected_spec, opts)
      resource.provider.api_urls = ['http://10.0.0.1:8080','http://10.0.0.2:8080','http://10.0.0.3:8080']
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a check' do
      opts = {
        :api_group => 'enterprise/federation',
        :api_version => 'v1',
        :method => 'delete',
      }
      expect(resource.provider).to receive(:api_request).with('clusters/test', nil, opts)
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

