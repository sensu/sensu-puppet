require 'spec_helper'

describe Puppet::Type.type(:sensu_event).provider(:sensuctl) do
  before(:each) do
    @provider = described_class
    @type = Puppet::Type.type(:sensu_event)
    @resource = @type.new({
      :name => 'keepalive for test'
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(@provider).to receive(:sensuctl_list).with('event').and_return(my_fixture_read('event_list.json'))
      expect(@provider.instances.length).to eq(1)
    end

    it 'should return the resource for a event' do
      allow(@provider).to receive(:sensuctl_list).with('event').and_return(my_fixture_read('event_list.json'))
      property_hash = @provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('keepalive for sensu-backend.example.com')
      expect(property_hash[:entity]).to eq('sensu-backend.example.com')
      expect(property_hash[:check]).to eq('keepalive')
    end
  end

  describe 'resolve' do
    it 'should create a event' do
      expect(@resource.provider).to receive(:sensuctl).with(['event', 'resolve', 'test', 'keepalive', '--organization', 'default', '--environment', 'default'])
      @resource.provider.resolve
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:resolve)
    end
  end

  describe 'destroy' do
    it 'should delete a event' do
      expect(@resource.provider).to receive(:sensuctl).with(['event', 'delete', 'test', 'keepalive', '--skip-confirm'])
      @resource.provider.destroy
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

