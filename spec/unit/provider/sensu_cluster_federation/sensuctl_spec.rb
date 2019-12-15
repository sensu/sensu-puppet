require 'spec_helper'

describe Puppet::Type.type(:sensu_cluster_federation).provider(:sensuctl) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_cluster_federation) }
  let(:resource) do
    type.new({
      :name => 'test',
      :api_urls => ['http://10.0.0.1:8080','http://10.0.0.2:8080'],
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:sensuctl).with(['dump','federation/v1.Cluster','--format','yaml','--all-namespaces']).and_return(my_fixture_read('dump.out'))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a check' do
      allow(provider).to receive(:sensuctl).with(['dump','federation/v1.Cluster','--format','yaml','--all-namespaces']).and_return(my_fixture_read('dump.out'))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('test')
    end
  end

  describe 'create' do
    it 'should create a federated cluster' do
      expected_metadata = {
        :name => 'test',
      }
      expected_spec = {
        :api_urls => ['http://10.0.0.1:8080','http://10.0.0.2:8080'],
      }
      expect(resource.provider).to receive(:sensuctl_create).with('Cluster', expected_metadata, expected_spec, 'federation/v1')
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a check proxy_requests' do
      expected_metadata = {
        :name => 'test',
      }
      expected_spec = {
        :api_urls => ['http://10.0.0.1:8080','http://10.0.0.2:8080','http://10.0.0.3:8080'],
      }
      expect(resource.provider).to receive(:sensuctl_create).with('Cluster', expected_metadata, expected_spec, 'federation/v1')
      resource.provider.api_urls = ['http://10.0.0.1:8080','http://10.0.0.2:8080','http://10.0.0.3:8080']
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a check' do
      expected_metadata = {
        :name => 'test',
      }
      expected_spec = {
        :api_urls => ['http://10.0.0.1:8080','http://10.0.0.2:8080'],
      }
      expect(resource.provider).to receive(:sensuctl_delete).with('Cluster', 'test', nil, expected_metadata, expected_spec, 'federation/v1')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

