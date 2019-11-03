require 'spec_helper'

describe Puppet::Type.type(:sensu_config).provider(:sensuctl) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_config) }
  let(:resource) do
    type.new({
      :name => 'format',
      :value => 'json',
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:sensuctl).with(['config','view','--format','json']).and_return(my_fixture_read('config_list.json'))
      expect(provider.instances.length).to eq(3)
    end

    it 'should return the resource for a config' do
      allow(provider).to receive(:sensuctl).with(['config','view','--format','json']).and_return(my_fixture_read('config_list.json'))
      property_hash = provider.instances.select { |i| i.name == 'format' }[0].instance_variable_get("@property_hash")
      expect(property_hash[:value]).to eq('tabular')
    end
  end

  describe 'create' do
    it 'should create a config' do
      expect(resource.provider).to receive(:sensuctl).with(['config', 'set-format', 'json'])
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a config' do
      expect(resource.provider).to receive(:sensuctl).with(['config', 'set-format', 'foobar'])
      resource.provider.value = 'foobar'
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should not support deleting a config' do
      expect(Puppet).to receive(:warning).with(/sensu_config does not support ensure=absent/)
      resource.provider.destroy
    end
  end
end

