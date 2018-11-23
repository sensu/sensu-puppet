require 'spec_helper'

describe Puppet::Type.type(:sensu_role).provider(:sensuctl) do
  before(:each) do
    @provider = described_class
    @type = Puppet::Type.type(:sensu_role)
    @resource = @type.new({
      :name => 'test',
      :rules => [{'type' => '*', 'namespace' => '*', 'permissions' => ['read']}],
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(@provider).to receive(:sensuctl_list).with('role').and_return(my_fixture_read('role_list.json'))
      expect(@provider.instances.length).to eq(2)
    end

    it 'should return the resource for a role' do
      allow(@provider).to receive(:sensuctl_list).with('role').and_return(my_fixture_read('role_list.json'))
      property_hash = @provider.instances.select {|i| i.name == 'read-only'}[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('read-only')
      expect(property_hash[:rules]).to include({'type' => '*', 'namespace' => '*', 'permissions' => ['read']})
    end
  end

  describe 'create' do
    it 'should create a role' do
      expected_spec = {
        :name => 'test',
        :rules => [{'type' => '*', 'namespace' => '*', 'permissions' => ['read']}]
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('role', expected_spec)
      @resource.provider.create
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a role rule' do
      expected_spec = {
        :name => 'test',
        :rules => [{'type' => '*', 'namespace' => '*', 'permissions' => ['read','create']}]
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('role', expected_spec)
      @resource.provider.rules = [{'type' => '*', 'namespace' => '*', 'permissions' => ['read','create']}]
      @resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a role' do
      expect(@resource.provider).to receive(:sensuctl_delete).with('role', 'test')
      @resource.provider.destroy
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

