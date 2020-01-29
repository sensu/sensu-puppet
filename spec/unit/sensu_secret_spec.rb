require 'spec_helper'
require 'puppet/type/sensu_secret'

describe Puppet::Type.type(:sensu_secret) do
  let(:default_config) do
    {
      name: 'test',
      id: 'test',
      secrets_provider: 'env',
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

  it 'should handle composite title' do
    config.delete(:namespace)
    config[:name] = 'test in dev'
    expect(resource[:name]).to eq('test in dev')
    expect(resource[:resource_name]).to eq('test')
    expect(resource[:namespace]).to eq('dev')
  end

  it 'should handle non-composite title' do
    config[:name] = 'test'
    expect(resource[:name]).to eq('test')
    expect(resource[:resource_name]).to eq('test')
    expect(resource[:namespace]).to eq('default')
  end

  it 'should handle composite title and namespace' do
    config[:namespace] = 'test'
    config[:name] = 'test in qa'
    expect(resource[:resource_name]).to eq('test')
    expect(resource[:namespace]).to eq('test')
  end

  defaults = {}

  # String properties
  [
    :id,
    :secrets_provider,
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

  include_examples 'autorequires' do
    let(:res) { resource }
  end

  it 'should autorequire sensu_secrets_provider' do
    secrets_provider = Puppet::Type.type(:sensu_secrets_vault_provider).new(:name => 'test', :address => 'foo', :token => 'secret', :version => 'v1')
    catalog = Puppet::Resource::Catalog.new
    config[:secrets_provider] = 'test'
    catalog.add_resource resource
    catalog.add_resource secrets_provider
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(secrets_provider.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  [
    :id,
    :secrets_provider,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { resource.pre_run_check }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end

  include_examples 'namespace' do
    let(:res) { resource }
  end
end
