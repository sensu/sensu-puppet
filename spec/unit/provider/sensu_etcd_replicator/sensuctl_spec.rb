require 'spec_helper'

describe Puppet::Type.type(:sensu_etcd_replicator).provider(:sensuctl) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_etcd_replicator) }
  let(:resource) do
    type.new({
      :name => 'test',
      :ca_cert => '/path/to/ssl/trusted-certificate-authorities.pem',
      :cert => '/path/to/ssl/cert.pem',
      :key => '/path/to/ssl/key.pem',
      :url => 'http://127.0.0.1:2379',
      :resource_name => 'Role',
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:sensuctl).with(['dump','federation/v1.EtcdReplicator','--format','yaml','--all-namespaces']).and_return(my_fixture_read('dump.txt'))
      expect(provider.instances.length).to eq(2)
    end

    it 'should return the resource for a check' do
      allow(provider).to receive(:sensuctl).with(['dump','federation/v1.EtcdReplicator','--format','yaml','--all-namespaces']).and_return(my_fixture_read('dump.txt'))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('role_replicator')
    end
  end

  describe 'create' do
    it 'should create a check' do
      expected_metadata = {
        :name => 'test',
      }
      expected_spec = {
        :ca_cert => '/path/to/ssl/trusted-certificate-authorities.pem',
        :cert => '/path/to/ssl/cert.pem',
        :key => '/path/to/ssl/key.pem',
        :insecure => false,
        :url => 'http://127.0.0.1:2379',
        :resource => 'Role',
        :api_version => 'core/v2',
        :replication_interval_seconds => 30,
      }
      expect(resource.provider).to receive(:sensuctl_create).with('EtcdReplicator', expected_metadata, expected_spec, 'federation/v1')
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
        :ca_cert => '/path/to/ssl/trusted-certificate-authorities.pem',
        :cert => '/path/to/ssl/cert.pem',
        :key => '/path/to/ssl/key.pem',
        :insecure => false,
        :url => 'http://127.0.0.1:2379',
        :resource => 'Role',
        :api_version => 'core/v2',
        :replication_interval_seconds => 60,
      }
      expect(resource.provider).to receive(:sensuctl_create).with('EtcdReplicator', expected_metadata, expected_spec, 'federation/v1')
      resource.provider.replication_interval_seconds = 60
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a check' do
      expected_metadata = {
        :name => 'test',
      }
      expected_spec = {
        :ca_cert => '/path/to/ssl/trusted-certificate-authorities.pem',
        :cert => '/path/to/ssl/cert.pem',
        :key => '/path/to/ssl/key.pem',
        :insecure => false,
        :url => 'http://127.0.0.1:2379',
        :resource => 'Role',
        :api_version => 'core/v2',
        :replication_interval_seconds => 30,
      }
      expect(resource.provider).to receive(:sensuctl_delete).with('EtcdReplicator', 'test', nil, expected_metadata, expected_spec, 'federation/v1')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

