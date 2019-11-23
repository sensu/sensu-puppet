require 'spec_helper'

describe Puppet::Type.type(:sensu_role_binding).provider(:sensu_api) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_role_binding) }
  let(:resource) do
    type.new({
      :name => 'test',
      :role_ref => {'type' => 'Role', 'name' => 'test-role'},
      :subjects => [{'type' => 'User', 'name' => 'test-user'}],
      :provider => 'sensu_api',
    })
  end

  before(:each) do
    allow(provider).to receive(:namespaces).and_return(['default'])
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:api_request).with('rolebindings', nil, {:namespace => 'default'}).and_return(JSON.parse(my_fixture_read('list.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a role_binding' do
      allow(provider).to receive(:api_request).with('rolebindings', nil, {:namespace => 'default'}).and_return(JSON.parse(my_fixture_read('list.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('test in default')
      expect(property_hash[:role_ref]).to eq({'type' => 'Role', 'name' => 'test'})
    end
  end

  describe 'create' do
    it 'should create a role_binding' do
      expected_spec = {
        :role_ref => {'type' => 'Role', 'name' => 'test-role'},
        :subjects => [{'type' => 'User', 'name' => 'test-user'}],
        :metadata => {
          :name => 'test',
          :namespace => 'default',
        },
      }
      expect(resource.provider).to receive(:api_request).with('rolebindings', expected_spec, {:namespace => 'default', :method => 'post'})
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a role_binding subjects' do
      expected_spec = {
        :role_ref => {'type' => 'Role', 'name' => 'test-role'},
        :subjects => [{'type' => 'User', 'name' => 'test'}],
        :metadata => {
          :name => 'test',
          :namespace => 'default',
        },
      }
      expect(resource.provider).to receive(:api_request).with('rolebindings/test', expected_spec, {:namespace => 'default', :method => 'put'})
      resource.provider.subjects = [{'type' => 'User', 'name' => 'test'}]
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a role_binding' do
      expect(resource.provider).to receive(:api_request).with('rolebindings/test', nil, {:namespace => 'default', :method => 'delete'})
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

