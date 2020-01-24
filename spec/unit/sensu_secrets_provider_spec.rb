require 'spec_helper'
require 'puppet/type/sensu_secrets_provider'

describe Puppet::Type.type(:sensu_secrets_provider) do
  let(:default_config) do
    {
      name: 'vault',
      client: {
        'address' => 'https://vaultserver.example.com:8200',
        'token' => 'secret',
        'version' => 'v1',
      }
    }
  end
  let(:config) do
    default_config
  end
  let(:resource) do
    described_class.new(config)
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource resource
    }.to_not raise_error
  end

  it 'should require a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  defaults = {}

  # String properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 'foo'
      expect(resource[property]).to eq('foo')
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(resource[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(resource[property]).to eq(default_config[property])
      end
    end
  end

  # String regex validated properties
  [
  ].each do |property|
    it "should not accept invalid #{property}" do
      config[property] = 'foo bar'
      expect { resource }.to raise_error(Puppet::Error, /#{property.to_s} invalid/)
    end
  end

  # Array properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = ['foo', 'bar']
      expect(resource[property]).to eq(['foo', 'bar'])
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(resource[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(resource[property]).to eq(default_config[property])
      end
    end
  end

  # Integer properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 30
      expect(resource[property]).to eq(30)
    end
    it "should accept valid #{property} as string" do
      config[property] = '30'
      expect(resource[property]).to eq(30)
    end
    it "should not accept invalid value for #{property}" do
      config[property] = 'foo'
      expect { resource }.to raise_error(Puppet::Error, /should be an Integer/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(resource[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(resource[property]).to eq(default_config[property])
      end
    end
  end

  # Boolean properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = true
      expect(resource[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = false
      expect(resource[property]).to eq(:false)
    end
    it "should accept valid #{property}" do
      config[property] = 'true'
      expect(resource[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = 'false'
      expect(resource[property]).to eq(:false)
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { resource }.to raise_error(Puppet::Error, /Invalid value "foo". Valid values are true, false/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(resource[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(resource[property]).to eq(default_config[property])
      end
    end
  end

  # Hash properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = { 'foo': 'bar' }
      expect(resource[property]).to eq({'foo': 'bar'})
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { resource }.to raise_error(Puppet::Error, /should be a Hash/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(resource[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(resource[property]).to eq(default_config[property])
      end
    end
  end

  describe 'type' do
    it 'has default' do
      expect(resource[:type]).to eq('VaultProvider')
    end
  end

  describe 'client' do
    it 'should accept servers and apply defaults' do
      expected = {
        'address' => 'https://vaultserver.example.com:8200',
        'token' => 'secret',
        'version' => 'v1',
        'max_retries' => 2,
        'timeout' => '60s',
        'agent_address' => '',
        'tls' => nil,
        'rate_limiter' => nil,
      }
      expect(resource[:client]).to eq(expected)
    end
    it 'should be required hash' do
      config[:client] = ['foo']
      expect { resource }.to raise_error(Puppet::Error, /Hash/)
    end
    it 'should require address' do
      config[:client] = {'token' => 'secret','version' => 'v1'}
      expect { resource }.to raise_error(Puppet::Error, /client requires key address/)
    end
    it 'should require token' do
      config[:client] = {'address' => 'https://foo.example.com','version' => 'v1'}
      expect { resource }.to raise_error(Puppet::Error, /client requires key token/)
    end
    it 'should require version' do
      config[:client] = {'address' => 'https://foo.example.com','token' => 'secret'}
      expect { resource }.to raise_error(Puppet::Error, /client requires key version/)
    end
    it 'should require a hash for tls' do
      config[:client]['tls'] = 'foo'
      expect { resource }.to raise_error(Puppet::Error, /must be a Hash/)
    end
    it 'should not accept invalid key for tls' do
      config[:client]['tls'] = {'foo' => 'bar'}
      expect { resource }.to raise_error(Puppet::Error, /foo/)
    end
    it 'accepts valid value for rate_limiter' do
      config[:client] = default_config[:client].merge({'rate_limiter' => {'limit' => 10, 'burst' => 100}})
      expect(resource[:client]['rate_limiter']).to eq({'limit' => 10, 'burst' => 100})
    end
    it 'raises error if rate_limiter not hash' do
      config[:client]['rate_limiter'] = ['foo']
      expect { resource }.to raise_error(/Hash/)
    end
    it 'does not accept invalid key for rate_limiter' do
      config[:client]['rate_limiter'] = {'foo' => 'bar', 'limit' => 10, 'burst' => 100}
      expect { resource }.to raise_error(/not a valid key for rate_limiter/)
    end
    it 'requires client for VaultProvider' do
      config[:ensure] = :present
      config[:type] = 'VaultProvider'
      config.delete(:client)
      expect { resource }.to raise_error(/must provider client property/)
    end
  end

  include_examples 'autorequires', false do
    let(:res) { resource }
  end

  [
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { resource }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end
end
