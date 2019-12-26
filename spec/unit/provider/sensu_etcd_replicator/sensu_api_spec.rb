require 'spec_helper'

describe Puppet::Type.type(:sensu_etcd_replicator).provider(:sensu_api) do
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
      :provider => 'sensu_api',
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      opts = {
        :api_group => 'enterprise/federation',
        :api_version => 'v1',
      }
      allow(provider).to receive(:api_request).with('etcd-replicators', nil, opts).and_return(JSON.parse(my_fixture_read('get.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a check' do
      opts = {
        :api_group => 'enterprise/federation',
        :api_version => 'v1',
      }
      allow(provider).to receive(:api_request).with('etcd-replicators', nil, opts).and_return(JSON.parse(my_fixture_read('get.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('role_replicator')
    end
  end

  describe 'create' do
    it 'should create a check' do
      expected_spec = {
        :spec => {
          :ca_cert => '/path/to/ssl/trusted-certificate-authorities.pem',
          :cert => '/path/to/ssl/cert.pem',
          :key => '/path/to/ssl/key.pem',
          :insecure => false,
          :url => 'http://127.0.0.1:2379',
          :resource => 'Role',
          :api_version => 'core/v2',
          :replication_interval_seconds => 30,
        },
        :metadata => { :name => 'test' },
        :api_version => 'federation/v1',
        :type => 'EtcdReplicator',
      }
      opts = {
        :api_group => 'enterprise/federation',
        :api_version => 'v1',
        :method => 'post',
      }
      expect(resource.provider).to receive(:api_request).with('etcd-replicators', expected_spec, opts)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a check proxy_requests' do
      expected_spec = {
        :spec => {
          :ca_cert => '/path/to/ssl/trusted-certificate-authorities.pem',
          :cert => '/path/to/ssl/cert.pem',
          :key => '/path/to/ssl/key.pem',
          :insecure => false,
          :url => 'http://127.0.0.1:2379',
          :resource => 'Role',
          :api_version => 'core/v2',
          :replication_interval_seconds => 60,
        },
        :metadata => { :name => 'test' },
        :api_version => 'federation/v1',
        :type => 'EtcdReplicator',
      }
      opts = {
        :api_group => 'enterprise/federation',
        :api_version => 'v1',
        :method => 'put',
      }
      expect(resource.provider).to receive(:api_request).with('etcd-replicators/test', expected_spec, opts)
      resource.provider.replication_interval_seconds = 60
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
      expect(resource.provider).to receive(:api_request).with('etcd-replicators/test', nil, opts)
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

