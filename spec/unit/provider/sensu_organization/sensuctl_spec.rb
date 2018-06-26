require 'spec_helper'

describe Puppet::Type.type(:sensu_organization).provider(:sensuctl) do
  before(:each) do
    @provider = described_class
    @type = Puppet::Type.type(:sensu_organization)
    @resource = @type.new({
      :name => 'test',
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(@provider).to receive(:sensuctl_list).with('organization').and_return(my_fixture_read('organization_list.json'))
      expect(@provider.instances.length).to eq(1)
    end

    it 'should return the resource for a organization' do
      allow(@provider).to receive(:sensuctl_list).with('organization').and_return(my_fixture_read('organization_list.json'))
      property_hash = @provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('default')
    end
  end

  describe 'create' do
    it 'should create a organization' do
      expected_spec = {
        :name => 'test',
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('organization', expected_spec)
      @resource.provider.create
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a organization' do
      expected_spec = {
        :name => 'test',
        :description => 'test'
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('organization', expected_spec)
      @resource.provider.description = 'test'
      @resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a organization' do
      expect(@resource.provider).to receive(:sensuctl_delete).with('organization', 'test')
      @resource.provider.destroy
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

