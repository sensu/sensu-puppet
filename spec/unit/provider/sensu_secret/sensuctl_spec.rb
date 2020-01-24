require 'spec_helper'

describe Puppet::Type.type(:sensu_secret).provider(:sensuctl) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_secret) }
  let(:config) do
    {
      :name => 'test',
      :id => 'test',
      :secrets_provider => 'env',
    }
  end
  let(:resource) do
    type.new(config)
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:sensuctl_list).with('secret').and_return(JSON.parse(my_fixture_read('list.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a secret' do
      allow(provider).to receive(:sensuctl_list).with('secret').and_return(JSON.parse(my_fixture_read('list.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('sensu-ansible in default')
    end
  end

  describe 'create' do
    it 'should create a secret' do
      expected_metadata = {
        :name => 'test',
        :namespace => 'default',
      }
      expected_spec = {
        :id => 'test',
        :provider => 'env',
      }
      expect(resource.provider).to receive(:sensuctl_create).with('Secret', expected_metadata, expected_spec, 'secrets/v1')
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a secret' do
      expected_metadata = {
        :name => 'test',
        :namespace => 'default',
      }
      expected_spec = {
        :id => 'tests',
        :provider => 'env'
      }
      expect(resource.provider).to receive(:sensuctl_create).with('Secret', expected_metadata, expected_spec, 'secrets/v1')
      resource.provider.id = 'tests'
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a secret' do
      expect(resource.provider).to receive(:sensuctl_delete).with('secret', 'test', 'default')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

