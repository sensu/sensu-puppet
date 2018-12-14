require 'spec_helper'

describe Puppet::Type.type(:sensu_hook).provider(:sensuctl) do
  before(:each) do
    @provider = described_class
    @type = Puppet::Type.type(:sensu_hook)
    @resource = @type.new({
      :name => 'test',
      :command => 'test',
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(@provider).to receive(:sensuctl_list).with('hook').and_return(my_fixture_read('hook_list.json'))
      expect(@provider.instances.length).to eq(1)
    end

    it 'should return the resource for a hook' do
      allow(@provider).to receive(:sensuctl_list).with('hook').and_return(my_fixture_read('hook_list.json'))
      property_hash = @provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('process_tree')
    end
  end

  describe 'create' do
    it 'should create a hook' do
      expected_spec = {
        :metadata => {
          :name => 'test',
          :namespace => 'default',
        },
        :command => 'test',
        :timeout => 60,
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('HookConfig', expected_spec)
      @resource.provider.create
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a hook timeout' do
      expected_spec = {
        :metadata => {
          :name => 'test',
          :namespace => 'default',
        },
        :command => 'test',
        :timeout => 120
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('HookConfig', expected_spec)
      @resource.provider.timeout = 120
      @resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a hook' do
      expect(@resource.provider).to receive(:sensuctl_delete).with('hook', 'test')
      @resource.provider.destroy
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

