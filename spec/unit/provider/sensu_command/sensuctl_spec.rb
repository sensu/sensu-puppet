require 'spec_helper'

describe Puppet::Type.type(:sensu_command).provider(:sensuctl) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_command) }
  let(:sha512) { '67aeba3652def271b1921bc1b4621354ad254c89946ebc8d1e39327f69a902d91f4b0326c9020a4a03e4cfbb718b454b6180f9c39aaff1e60daf6310be66244f' }
  let(:config) do
    {
      :name => 'command-test',
      :url => 'http://foo.example.com',
      :sha512 => sha512,
    }
  end
  let(:resource) do
    type.new(config)
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:sensuctl_list).with('command', false).and_return(JSON.parse(my_fixture_read('list.json')))
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a command' do
      allow(provider).to receive(:sensuctl_list).with('command', false).and_return(JSON.parse(my_fixture_read('list.json')))
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('command-test')
    end
  end

  describe 'create' do
    it 'should create a command' do
      expected_cmd = ['command','install', 'command-test', '--url', 'http://foo.example.com', '--checksum', sha512]
      expect(resource.provider).to receive(:sensuctl).with(expected_cmd)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
    it 'should create from bonsai' do
      config.delete(:url)
      config.delete(:sha512)
      config[:bonsai_name] = 'sensu/command-test'
      expected_cmd = ['command','install','command-test', 'sensu/command-test']
      expect(resource.provider).to receive(:sensuctl).with(expected_cmd)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
    it 'should create a command for latest bonsai' do
      config.delete(:url)
      config.delete(:sha512)
      config[:bonsai_name] = 'sensu/command-test'
      config[:bonsai_version] = 'latest'
      expected_cmd = ['command','install','command-test', 'sensu/command-test']
      expect(resource.provider).to receive(:sensuctl).with(expected_cmd)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
    it 'should create a command for a version' do
      config.delete(:url)
      config.delete(:sha512)
      config[:bonsai_name] = 'sensu/command-test'
      config[:bonsai_version] = '0.4.0'
      expected_cmd = ['command','install','command-test', 'sensu/command-test:0.4.0']
      expect(resource.provider).to receive(:sensuctl).with(expected_cmd)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
    end
  end

  describe 'flush' do
    it 'should install latest bonsai asset' do
      config.delete(:url)
      config.delete(:sha512)
      config[:bonsai_name] = 'sensu/command-test'
      expect(resource.provider).to receive(:sensuctl_delete).with('command', 'command-test')
      expected_cmd = ['command','install','command-test', 'sensu/command-test']
      expect(resource.provider).to receive(:sensuctl).with(expected_cmd)
      resource.provider.bonsai_version = 'latest'
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a asset' do
      expect(resource.provider).to receive(:sensuctl_delete).with('command', 'command-test')
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

