require 'spec_helper'

describe Puppet::Type.type(:sensu_plugin).provider(:sensu_install) do
  let(:provider) { described_class }
  let(:type) { Puppet::Type.type(:sensu_plugin) }
  let(:resource) do
    type.new({
      :name => 'test',
      :ensure => 'present',
      :provider => provider.name,
    })
    #allow(Puppet::Util).to receive(:which).with('sensu-install').and_return('/bin/sensu-install')
  end

  let(:list_local_output) { "

*** LOCAL GEMS ***

sensu-plugins-disk-plugins (4.0.0)
"}

  let(:list_remote_output) { "

*** REMOTE GEMS ***

sensu-extensions-check-dependencies (1.1.0, 1.0.1, 1.0.0)
sensu-plugins-nvidia (1.0.0, 0.0.2, 0.0.1)
" }

  describe 'self.instances' do
    it 'should create instances' do
      allow(provider).to receive(:gem).with('list','--local','^sensu-(plugins|extensions)').and_return(list_local_output)
      expect(provider.instances.length).to eq(1)
    end

    it 'should return the resource for a plugin' do
      allow(provider).to receive(:gem).with('list','--local','^sensu-(plugins|extensions)').and_return(list_local_output)
      property_hash = provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('disk-plugins')
    end
  end

  describe 'self.latest_versions' do
    it 'should return latest versions' do
      allow(provider).to receive(:gem).with('search', '--remote', '--all', "^sensu-(plugins|extensions)-").and_return(list_remote_output)
      latest_versions = provider.latest_versions
      expect(latest_versions).to eq({'check-dependencies' => '1.1.0', 'nvidia' => '1.0.0'})
    end
  end

  describe 'create' do
    it 'should install a plugin' do
      expected_args = [
        '--plugin', 'test',
        '--clean',
      ]
      expect(resource.provider).to receive(:sensu_install).with(expected_args)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
    it 'should install an extension' do
      resource[:extension] = :true
      expected_args = [
        '--extension', 'test',
        '--clean',
      ]
      expect(resource.provider).to receive(:sensu_install).with(expected_args)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
    it 'should install specific version' do
      resource[:version] = '1.0.0'
      expected_args = [
        '--plugin', 'sensu-plugins-test:1.0.0',
        '--clean',
      ]
      expect(resource.provider).to receive(:sensu_install).with(expected_args)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
    it 'installs latest version' do
      resource[:name] = 'nvidia'
      resource[:version] = :latest
      allow(provider).to receive(:gem).with('search', '--remote', '--all', "^sensu-(plugins|extensions)-").and_return(list_remote_output)
      expected_args = [
        '--plugin', 'sensu-plugins-nvidia:1.0.0',
        '--clean',
      ]
      expect(resource.provider).to receive(:sensu_install).with(expected_args)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
    it 'should install a plugin without clean' do
      resource[:clean] = :false
      expected_args = [
        '--plugin', 'test',
      ]
      expect(resource.provider).to receive(:sensu_install).with(expected_args)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
    it 'should install a plugin with source' do
      resource[:source] = 'http://foo'
      expected_args = [
        '--plugin', 'test',
        '--clean',
        '--source', 'http://foo',
      ]
      expect(resource.provider).to receive(:sensu_install).with(expected_args)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
    it 'should install a plugin with proxy' do
      resource[:proxy] = 'http://foo'
      expected_args = [
        '--plugin', 'test',
        '--clean',
        '--proxy', 'http://foo',
      ]
      expect(resource.provider).to receive(:sensu_install).with(expected_args)
      resource.provider.create
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should install specific version' do
      expected_args = [
        '--plugin', 'sensu-plugins-test:1.0.0',
        '--clean',
      ]
      expect(resource.provider).to receive(:sensu_install).with(expected_args)
      resource.provider.version = '1.0.0'
      resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should uninstall a plugin' do
      expected_args = [
        'uninstall', 'sensu-plugins-test',
        '--executables', '--all'
      ]
      expect(resource.provider).to receive(:gem).with(expected_args)
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
    it 'should uninstall an extension' do
      resource[:extension] = :true
      expected_args = [
        'uninstall', 'sensu-extensions-test',
        '--executables', '--all'
      ]
      expect(resource.provider).to receive(:gem).with(expected_args)
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
    it 'should uninstall a plugin by version' do
      resource[:version] = '1.0.0'
      expected_args = [
        'uninstall', 'sensu-plugins-test',
        '--executables',
        '--version', '1.0.0',
      ]
      expect(resource.provider).to receive(:gem).with(expected_args)
      resource.provider.destroy
      property_hash = resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end

