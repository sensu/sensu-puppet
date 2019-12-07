require 'spec_helper'

describe Puppet::Type.type(:sensu_cluster_member).provider(:sensu_api) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_cluster_member) }
  let(:resource) do
    type.new({
      :name => 'test',
      :peer_urls => ['http://127.0.0.1:2380'],
      :provider => 'sensu_api',
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:api_request).with('cluster/members').and_return(JSON.parse(my_fixture_read('cluster_member_list.json')))
      expect(provider.instances.length).to eq(3)
    end

    it 'should return the resource for a cluster_member' do
      allow(provider).to receive(:api_request).with('cluster/members').and_return(JSON.parse(my_fixture_read('cluster_member_list.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('backend3')
      expect(property_hash[:id]).to eq('74ae9e813b87882d')
    end
  end

  describe 'create' do
    it 'should add a cluster_member' do
      expect(resource.provider).to receive(:api_request).with('cluster/members', {'peer-addrs' => 'http://127.0.0.1:2380'}, {:method => 'post-form'})
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    before(:each) do
      hash = resource.provider.instance_variable_get(:@property_hash)
      hash[:id] = '74ae9e813b87882d'
      resource.provider.instance_variable_set(:@property_hash, hash)
    end

    it 'should update a cluster_member' do
      expect(resource.provider).to receive(:api_request).with('cluster/members/74ae9e813b87882d', {'peer-addrs' => 'http://localhost:2380'}, {:method => 'put-form'})
      resource.provider.peer_urls = ['http://localhost:2380']
      resource.provider.flush
    end
  end

  describe 'destroy' do
    before(:each) do
      hash = resource.provider.instance_variable_get(:@property_hash)
      hash[:id] = '74ae9e813b87882d'
      resource.provider.instance_variable_set(:@property_hash, hash)
    end

    it 'should delete a cluster_member' do
      expect(resource.provider).to receive(:api_request).with('cluster/members/74ae9e813b87882d', nil, {:method => 'delete'})
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

