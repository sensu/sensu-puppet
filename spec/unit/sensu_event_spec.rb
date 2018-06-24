require 'spec_helper'
require 'puppet/type/sensu_event'

describe Puppet::Type.type(:sensu_event) do
  let(:default_config) do
    {
      name: 'checkalive for test',
    }
  end
  let(:config) do
    default_config
  end
  let(:event) do
    described_class.new(config)
  end

  it 'should add to catalog with raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource event
    }.to_not raise_error
  end

  it 'should require a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should handle composite title check' do
    expect(event[:check]).to eq('checkalive')
  end

  it 'should handle composite title entity' do
    expect(event[:entity]).to eq('test')
  end

  it 'should allow ensure present' do
    event[:ensure] = 'present'
    expect(event[:ensure]).to eq(:present)
  end

  it 'should allow ensure resolve' do
    event[:ensure] = 'resolve'
    expect(event[:ensure]).to eq(:resolve)
  end

  it 'should allow ensure delete aliased to absent' do
    event[:ensure] = 'delete'
    expect(event[:ensure]).to eq(:absent)
  end

  it 'should allow ensure absent' do
    event[:ensure] = 'absent'
    expect(event[:ensure]).to eq(:absent)
  end

  it 'should not allow unsupported ensure' do
    expect {
      event[:ensure] = 'foo'
    }.to raise_error(Puppet::Error, /Invalid value "foo"/)
  end

  defaults = {
    'organization': 'default',
    'environment': 'default',
  }

  # String properties
  [
    :organization,
    :environment,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 'foo'
      expect(event[property]).to eq('foo')
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(event[property]).to eq(default)
      end
    end
  end

  # String regex validated properties
  [
  ].each do |property|
    it "should not accept invalid #{property}" do
      config[property] = 'foo bar'
      expect { event }.to raise_error(Puppet::Error, /#{property.to_s} invalid/)
    end
  end

  # Array properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = ['foo', 'bar']
      expect(event[property]).to eq(['foo', 'bar'])
    end
  end

  # Integer properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 30
      expect(event[property]).to eq(30)
    end
    it "should accept valid #{property} as string" do
      config[property] = '30'
      expect(event[property]).to eq(30)
    end
    it "should not accept invalid value for #{property}" do
      config[property] = 'foo'
      expect { event }.to raise_error(Puppet::Error, /should be an Integer/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(event[property]).to eq(default)
      end
    end
  end

  # Boolean properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = true
      expect(event[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = false
      expect(event[property]).to eq(:false)
    end
    it "should accept valid #{property}" do
      config[property] = 'true'
      expect(event[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = 'false'
      expect(event[property]).to eq(:false)
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { event }.to raise_error(Puppet::Error, /Invalid value "foo". Valid values are true, false/)
    end
  end

  # Hash properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = { 'foo': 'bar' }
      expect(event[property]).to eq({'foo': 'bar'})
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { event }.to raise_error(Puppet::Error, /should be a Hash/)
    end
  end

  it 'should autorequire Package[sensu-cli]' do
    package = Puppet::Type.type(:package).new(:name => 'sensu-cli')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource event
    catalog.add_resource package
    rel = event.autorequire[0]
    expect(rel.source.ref).to eq(package.ref)
    expect(rel.target.ref).to eq(event.ref)
  end

  it 'should autorequire Service[sensu-backend]' do
    service = Puppet::Type.type(:service).new(:name => 'sensu-backend')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource event
    catalog.add_resource service
    rel = event.autorequire[0]
    expect(rel.source.ref).to eq(service.ref)
    expect(rel.target.ref).to eq(event.ref)
  end

  it 'should autorequire Exec[sensuctl_configure]' do
    exec = Puppet::Type.type(:exec).new(:name => 'sensuctl_configure', :command => '/usr/bin/sensuctl')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource event
    catalog.add_resource exec
    rel = event.autorequire[0]
    expect(rel.source.ref).to eq(exec.ref)
    expect(rel.target.ref).to eq(event.ref)
  end

  it 'should autorequire sensu_api_validator' do
    validator = Puppet::Type.type(:sensu_api_validator).new(:name => 'sensu')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource event
    catalog.add_resource validator
    rel = event.autorequire[0]
    expect(rel.source.ref).to eq(validator.ref)
    expect(rel.target.ref).to eq(event.ref)
  end

  [
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { event }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end

  it "should require check and entity" do
    config[:name] = "test"
    expect { event }.to raise_error(Puppet::Error, /Must provide check and entity/)
  end
end
