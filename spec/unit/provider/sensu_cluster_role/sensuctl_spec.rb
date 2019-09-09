require 'spec_helper'

describe Puppet::Type.type(:sensu_cluster_role).provider(:sensuctl) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_cluster_role) }
  let(:resource) do
    type.new({
      :name => 'test',
      :rules => [{'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => ['']}]
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:sensuctl_list).with('cluster-role', false).and_return(JSON.parse(my_fixture_read('cluster_role_list.json')))
      expect(provider.instances.length).to eq(6)
    end

    it 'should return the resource for a cluster_role' do
      allow(provider).to receive(:sensuctl_list).with('cluster-role', false).and_return(JSON.parse(my_fixture_read('cluster_role_list.json')))
      property_hash = provider.instances.select {|i| i.name == 'cluster-admin'}[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('cluster-admin')
      expect(property_hash[:rules]).to include({'verbs' => ['*'], 'resources' => ['*'], 'resource_names' => nil})
    end
  end

  describe 'create' do
    it 'should create a cluster_role' do
      expected_metadata = {
        :name => 'test',
      }
      expected_spec = {
        :rules => [{'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => ['']}],
      }
      expect(resource.provider).to receive(:sensuctl_create).with('ClusterRole', expected_metadata, expected_spec)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a cluster_role rule' do
      expected_metadata = {
        :name => 'test',
      }
      expected_spec = {
        :rules => [{'verbs' => ['get','list'], 'resources' => ['*'], 'resource_names' => ['']}],
      }
      expect(resource.provider).to receive(:sensuctl_create).with('ClusterRole', expected_metadata, expected_spec)
      resource.provider.rules = [{'verbs' => ['get','list'], 'resources' => ['*'], 'resource_names' => ['']}]
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a cluster_role' do
      expect(resource.provider).to receive(:sensuctl_delete).with('cluster-role', 'test')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

