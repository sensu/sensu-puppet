require 'spec_helper'
require 'puppet/type/sensu_etcd_replicator'

describe Puppet::Type.type(:sensu_etcd_replicator) do
  let(:default_config) do
    {
      name: 'role_replicator',
      ca_cert: '/path/to/ssl/trusted-certificate-authorities.pem',
      cert: '/path/to/ssl/cert.pem',
      key: '/path/to/ssl/key.pem',
      url: 'http://127.0.0.1:2379',
      resource_name: 'Role',
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
    insecure: :false,
    api_version: 'core/v2',
    replication_interval_seconds: 30,
  }

  # String properties
  [
    :api_version,
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
    :replication_interval_seconds,
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
    :insecure,
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

  describe 'security' do
    it 'should require ca_cert' do
      config[:insecure] = false
      config.delete(:ca_cert)
      expect { resource.pre_run_check }.to raise_error(Puppet::Error, /ca_cert is required/)
    end
    it 'should require cert' do
      config[:insecure] = false
      config.delete(:cert)
      expect { resource.pre_run_check }.to raise_error(Puppet::Error, /cert is required/)
    end
    it 'should require key' do
      config[:insecure] = false
      config.delete(:key)
      expect { resource.pre_run_check }.to raise_error(Puppet::Error, /key is required/)
    end
  end

  include_examples 'autorequires', false do
    let(:res) { resource }
  end

  [
    :url,
    :resource_name,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { resource.pre_run_check }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end
end
