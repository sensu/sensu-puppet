require 'spec_helper'

describe Puppet::Type.type(:sensu_asset).provider(:sensuctl) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_asset) }
  let(:resource) do
    type.new({
      :name => 'test',
      :url => 'http://127.0.0.1',
      :sha512 => '4f926bf4328fbad2b9cac873d117f771914f4b837c9c85584c38ccf55a3ef3c2e8d154812246e5dda4a87450576b2c58ad9ab40c9e2edc31b288d066b195b21b'
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:sensuctl_list).with('asset').and_return(JSON.parse(my_fixture_read('asset_list.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a asset' do
      allow(provider).to receive(:sensuctl_list).with('asset').and_return(JSON.parse(my_fixture_read('asset_list.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('check-cpu.sh in default')
    end
  end

  describe 'create' do
    it 'should create a asset' do
      resource[:filters] = ["entity.system.os == 'linux'"]
      expected_metadata = {
        :name => 'test',
        :namespace => 'default',
      }
      expected_spec = {
        :url => 'http://127.0.0.1',
        :sha512 => '4f926bf4328fbad2b9cac873d117f771914f4b837c9c85584c38ccf55a3ef3c2e8d154812246e5dda4a87450576b2c58ad9ab40c9e2edc31b288d066b195b21b',
        :filters => ["entity.system.os == 'linux'"],
      }
      expect(resource.provider).to receive(:sensuctl_create).with('Asset', expected_metadata, expected_spec)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a asset filters' do
      resource[:filters] = ["entity.system.os == 'linux'"]
      expected_metadata = {
        :name => 'test',
        :namespace => 'default',
      }
      expected_spec = {
        :url => 'http://127.0.0.1',
        :sha512 => '4f926bf4328fbad2b9cac873d117f771914f4b837c9c85584c38ccf55a3ef3c2e8d154812246e5dda4a87450576b2c58ad9ab40c9e2edc31b288d066b195b21b',
        :filters => ["entity.system.os == 'windows'"],
      }
      expect(resource.provider).to receive(:sensuctl_create).with('Asset', expected_metadata, expected_spec)
      resource.provider.filters = ["entity.system.os == 'windows'"]
      resource.provider.flush
    end
    it 'should remove filters' do
      resource[:filters] = ["entity.system.os == 'linux'"]
      expected_metadata = {
        :name => 'test',
        :namespace => 'default',
      }
      expected_spec = {
        :url => 'http://127.0.0.1',
        :sha512 => '4f926bf4328fbad2b9cac873d117f771914f4b837c9c85584c38ccf55a3ef3c2e8d154812246e5dda4a87450576b2c58ad9ab40c9e2edc31b288d066b195b21b',
        :filters => nil,
      }
      expect(resource.provider).to receive(:sensuctl_create).with('Asset', expected_metadata, expected_spec)
      resource.provider.filters = :absent
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a asset' do
      expect(resource.provider).to receive(:sensuctl_delete).with('asset', 'test', 'default')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

