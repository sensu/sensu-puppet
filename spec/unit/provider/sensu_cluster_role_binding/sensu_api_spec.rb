require 'spec_helper'

describe Puppet::Type.type(:sensu_cluster_role_binding).provider(:sensu_api) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_cluster_role_binding) }
  let(:resource) do
    type.new({
      :name => 'test',
      :role_ref => {'type' => 'ClusterRole', 'name' => 'test-role'},
      :subjects => [{'type' => 'User', 'name' => 'test-user'}],
      :provider => 'sensu_api',
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:api_request).with('clusterrolebindings').and_return(JSON.parse(my_fixture_read('list.json')))
      expect(provider.instances.length).to eq(3)
    end

    it 'should return the resource for a cluster_role_binding' do
      allow(provider).to receive(:api_request).with('clusterrolebindings').and_return(JSON.parse(my_fixture_read('list.json')))
      property_hash = provider.instances.select {|i| i.name == 'cluster-admin'}[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('cluster-admin')
      expect(property_hash[:role_ref]).to eq({'type' => 'ClusterRole', 'name' => 'cluster-admin'})
    end
  end

  describe 'create' do
    it 'should create a cluster_role_binding' do
      expected_spec = {
        :role_ref => {'type' => 'ClusterRole', 'name' => 'test-role'},
        :subjects => [{'type' => 'User', 'name' => 'test-user'}],
        :metadata => {:name => 'test'},
      }
      expect(resource.provider).to receive(:api_request).with('clusterrolebindings', expected_spec, {:method => 'post'})
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a cluster_role_binding subjects' do
      expected_metadata = {
        :name => 'test',
      }
      expected_spec = {
        :role_ref => {'type' => 'ClusterRole', 'name' => 'test-role'},
        :subjects => [{'type' => 'User', 'name' => 'test'}],
        :metadata => {:name => 'test'},
      }
      expect(resource.provider).to receive(:api_request).with('clusterrolebindings/test', expected_spec, {:method => 'put'})
      resource.provider.subjects = [{'type' => 'User', 'name' => 'test'}]
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a cluster_role_binding' do
      expect(resource.provider).to receive(:api_request).with('clusterrolebindings/test', nil, {:method => 'delete'})
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

