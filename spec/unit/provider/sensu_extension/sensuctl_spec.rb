require 'spec_helper'

describe Puppet::Type.type(:sensu_extension).provider(:sensuctl) do
  before(:each) do
    @provider = described_class
    @type = Puppet::Type.type(:sensu_extension)
    @resource = @type.new({
      :name => 'test',
      :url => 'http://127.0.0.1',
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(@provider).to receive(:sensuctl_list).with('extension').and_return(my_fixture_read('extension_list.json'))
      expect(@provider.instances.length).to eq(1)
    end

    it 'should return the resource for a extension' do
      allow(@provider).to receive(:sensuctl_list).with('extension').and_return(my_fixture_read('extension_list.json'))
      property_hash = @provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('test')
    end
  end

  describe 'create' do
    it 'should create a extension' do
      expected_spec = {
        :name => 'test',
        :url => 'http://127.0.0.1',
        :namespace => 'default',
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('extension', expected_spec)
      @resource.provider.create
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a extension filters' do
      @resource[:url] = 'http://127.0.0.1/test'
      expected_spec = {
        :name => 'test',
        :url => 'http://127.0.0.1/test',
        :namespace => 'default',
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('extension', expected_spec)
      @resource.provider.url = 'http://127.0.0.1/test'
      @resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a extension' do
      expect(@resource.provider).to receive(:sensuctl).with('extension', 'deregister', 'test')
      @resource.provider.destroy
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

