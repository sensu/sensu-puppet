require 'spec_helper'
require 'puppet/type/sensu_secrets_vault_provider'

describe Puppet::Type.type(:sensu_secrets_vault_provider) do
  let(:default_config) do
    {
      name: 'vault',
      address: 'https://vaultserver.example.com:8200',
      token: 'secret',
      version: 'v1',
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

  defaults = {
    max_retries: 2,
    timeout: '60s',
  }

  # String properties
  [
    :address,
    :token,
    :version,
    :timeout,
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
    :max_retries
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

  describe 'tls' do
    it 'should accept value and apply defaults' do
      expected = {
        'ca_cert' => '/dne',
        'ca_path' => '',
        'client_cert' => '',
        'client_key' => '',
        'cname' => '',
        'insecure' => false,
        'tls_server_name' => '',
      }
      config[:tls] = {'ca_cert' => '/dne'}
      expect(resource[:tls]).to eq(expected)
    end
    it 'should require a hash for tls' do
      config[:tls] = 'foo'
      expect { resource }.to raise_error(Puppet::Error, /should be a Hash/)
    end
    it 'should not accept invalid key for tls' do
      config[:tls] = {'foo' => 'bar'}
      expect { resource }.to raise_error(Puppet::Error, /foo/)
    end
  end

  describe 'rate_limiter' do
    it 'accepts valid value for rate_limiter' do
      config[:rate_limiter] = {'limit' => 10, 'burst' => 100}
      expect(resource[:rate_limiter]).to eq({'limit' => 10, 'burst' => 100})
    end
    it 'raises error if rate_limiter not hash' do
      config[:rate_limiter] = ['foo']
      expect { resource }.to raise_error(/Hash/)
    end
    it 'does not accept invalid key for rate_limiter' do
      config[:rate_limiter] = {'foo' => 'bar', 'limit' => 10, 'burst' => 100}
      expect { resource }.to raise_error(/not a valid key for rate_limiter/)
    end
  end

  include_examples 'autorequires', false do
    let(:res) { resource }
  end

  [
    :address,
    :version,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { resource }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end

  describe 'token validation' do
    it 'should require either token or token_file' do
      config.delete(:token)
      config.delete(:token_file)
      config[:ensure] = :present
      expect { resource }.to raise_error(Puppet::Error, /You must provide either token/)
    end
    it 'should require mutually exclusive token and token_file' do
      config[:token] = 'foo'
      config[:token_file] = '/foo'
      config[:ensure] = :present
      expect { resource }.to raise_error(Puppet::Error, /token and token_file are mutually exclusive/)
    end
  end
end
