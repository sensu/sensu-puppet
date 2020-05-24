require 'spec_helper'
require 'puppet/type/sensuctl_configure'

describe Puppet::Type.type(:sensuctl_configure) do
  let(:default_config) do
    {
      name: 'puppet',
      username: 'admin',
      password: 'P@ssw0rd!',
      url: 'http://localhost:8080',
    }
  end
  let(:config) do
    default_config
  end
  let(:configure) do
    described_class.new(config)
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource configure
    }.to_not raise_error
  end

  it 'should require a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  defaults = {
    trusted_ca_file: '/etc/sensu/ssl/ca.crt',
  }

  # String properties
  [
    :username,
    :password,
    :url,
    :trusted_ca_file,
    :config_namespace,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 'foo'
      expect(configure[property]).to eq('foo')
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(configure[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(configure[property]).to eq(default_config[property])
      end
    end
  end

  # String regex validated properties
  [
  ].each do |property|
    it "should not accept invalid #{property}" do
      config[property] = 'foo bar'
      expect { configure }.to raise_error(Puppet::Error, /#{property.to_s} invalid/)
    end
  end

  # Array properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = ['foo', 'bar']
      expect(configure[property]).to eq(['foo', 'bar'])
    end
  end

  # Integer properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 30
      expect(configure[property]).to eq(30)
    end
    it "should accept valid #{property} as string" do
      config[property] = '30'
      expect(configure[property]).to eq(30)
    end
    it "should not accept invalid value for #{property}" do
      config[property] = 'foo'
      expect { configure }.to raise_error(Puppet::Error, /should be an Integer/)
    end
  end

  # Boolean properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = true
      expect(configure[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = false
      expect(configure[property]).to eq(:false)
    end
    it "should accept valid #{property}" do
      config[property] = 'true'
      expect(configure[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = 'false'
      expect(configure[property]).to eq(:false)
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { configure }.to raise_error(Puppet::Error, /Invalid value "foo". Valid values are true, false/)
    end
  end

  # Hash properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      configure[property] = { 'foo': 'bar' }
      expect(configure[property]).to eq({'foo': 'bar'})
    end
    it "should not accept invalid #{property}" do
      configure[property] = 'foo'
      expect { configure }.to raise_error(Puppet::Error, /should be a Hash/)
    end
  end

  describe 'config_format' do
    it 'should not have default' do
      expect(configure[:config_format]).to be_nil
    end
    it 'should accept a valid value' do
      config[:config_format] = 'json'
      expect(configure[:config_format]).to eq('json')
    end
    it 'should not accept invalid value' do
      config[:config_format] = 'foo'
      expect { configure }.to raise_error(Puppet::Error, /Valid values are/)
    end
  end

  it 'should autorequire trusted_ca_file' do
    file = Puppet::Type.type(:file).new(:name => '/etc/sensu/ssl/ca.crt')
    config[:trusted_ca_file] = '/etc/sensu/ssl/ca.crt'
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource configure
    catalog.add_resource file
    rel = configure.autorequire[0]
    expect(rel.source.ref).to eq(file.ref)
    expect(rel.target.ref).to eq(configure.ref)
  end

  include_examples 'autorequires', false, false do
    let(:res) { configure }
  end

  [
    :username,
    :password,
    :url,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { configure }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end
end
