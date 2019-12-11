require 'spec_helper'

describe Puppet::Type.type(:sensu_handler).provider(:sensuctl) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_handler) }
  let(:resource) do
    type.new({
      :name => 'test',
      :command => 'test',
      :type => 'pipe'
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:sensuctl_list).with('handler').and_return(JSON.parse(my_fixture_read('handler_list.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a handler' do
      allow(provider).to receive(:sensuctl_list).with('handler').and_return(JSON.parse(my_fixture_read('handler_list.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('tcp_handler in default')
    end
  end

  describe 'create' do
    it 'should create a handler' do
      resource[:filters] = ["recurrence", "production"]
      resource[:socket] = {'host' => "localhost", 'port' => 9000}
      expected_metadata = {
        :name => 'test',
        :namespace => 'default',
      }
      expected_spec = {
        :type => :pipe,
        :command => 'test',
        :filters => ["recurrence", "production"],
        :socket => {"host" => "localhost", "port" => 9000}
      }
      expect(resource.provider).to receive(:sensuctl_create).with('Handler', expected_metadata, expected_spec)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a handler socket' do
      resource[:type] = 'tcp'
      expected_metadata = {
        :name => 'test',
        :namespace => 'default',
      }
      expected_spec = {
        :type => :tcp,
        :command => 'test',
        :socket => { 'host' => 'localhost', 'port' => 9001 }
      }
      expect(resource.provider).to receive(:sensuctl_create).with('Handler', expected_metadata, expected_spec)
      resource.provider.socket = {'host' => 'localhost', 'port' => 9001}
      resource.provider.flush
    end
    it 'should remove timeout' do
      expected_metadata = {
        :name => 'test',
        :namespace => 'default',
      }
      expected_spec = {
        :type => :pipe,
        :command => 'test',
        :timeout => nil,
      }
      resource[:timeout] = 60
      expect(resource.provider).to receive(:sensuctl_create).with('Handler', expected_metadata, expected_spec)
      resource.provider.timeout = :absent
      resource.provider.flush
    end
    it 'should remove handlers' do
      expected_metadata = {
        :name => 'test',
        :namespace => 'default',
      }
      expected_spec = {
        :type => :pipe,
        :command => 'test',
        :handlers => nil
      }
      resource[:handlers] = ['foo','bar']
      expect(resource.provider).to receive(:sensuctl_create).with('Handler', expected_metadata, expected_spec)
      resource.provider.handlers = :absent
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a handler' do
      expect(resource.provider).to receive(:sensuctl_delete).with('handler', 'test', 'default')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

