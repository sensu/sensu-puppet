require 'spec_helper'

describe Puppet::Type.type(:sensu_silenced).provider(:sensuctl) do
  before(:each) do
    @provider = described_class
    @type = Puppet::Type.type(:sensu_silenced)
    @resource = @type.new({
      :name => 'entity:test:*',
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(@provider).to receive(:sensuctl_list).with('silenced').and_return(my_fixture_read('silenced_list.json'))
      expect(@provider.instances.length).to eq(1)
    end

    it 'should return the resource for a silenced' do
      allow(@provider).to receive(:sensuctl_list).with('silenced').and_return(my_fixture_read('silenced_list.json'))
      property_hash = @provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:id]).to eq('entity:sensu-backend.example.com:*')
      expect(property_hash[:subscription]).to eq('entity:sensu-backend.example.com')
      expect(property_hash[:check]).to be_nil
    end
  end

  describe 'create' do
    it 'should create a silenced' do
      expected_spec = {
        :subscription => 'entity:test',
        :check => '*',
        :expire => -1,
        :expire_on_resolve => false,
        :organization => 'default',
        :environment => 'default',
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('silenced', expected_spec)
      @resource.provider.create
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    before(:each) do
      hash = @resource.provider.instance_variable_get(:@property_hash)
      hash[:id] = 'entity:test:*'
      @resource.provider.instance_variable_set(:@property_hash, hash)
    end

    it 'should update a silenced reason' do
      expected_spec = {
        :id => 'entity:test:*',
        :subscription => 'entity:test',
        :check => '*',
        :expire => -1,
        :expire_on_resolve => false,
        :organization => 'default',
        :environment => 'default',
        :reason => 'test',
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('silenced', expected_spec)
      @resource.provider.reason = 'test'
      @resource.provider.flush
    end
    it 'should update boolean' do
      @resource[:expire_on_resolve] = :true
      expected_spec = {
        :id => 'entity:test:*',
        :subscription => 'entity:test',
        :check => '*',
        :expire => -1,
        :organization => 'default',
        :environment => 'default',
        :expire_on_resolve => false,
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('silenced', expected_spec)
      @resource.provider.expire_on_resolve = :false
      @resource.provider.flush
    end
  end

  describe 'destroy' do
    before(:each) do
      hash = @resource.provider.instance_variable_get(:@property_hash)
      hash[:id] = 'entity:test:*'
      @resource.provider.instance_variable_set(:@property_hash, hash)
    end

    it 'should delete a silenced' do
      expect(@resource.provider).to receive(:sensuctl_delete).with('silenced', 'entity:test:*')
      @resource.provider.destroy
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

