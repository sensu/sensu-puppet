require 'spec_helper'
require 'puppet/type/sensu_filter'

describe Puppet::Type.type(:sensu_filter) do
  let(:default_config) do
    {
      name: 'test',
      action: 'allow',
      expressions: ['event.Check.Occurrences == 1']
    }
  end
  let(:config) do
    default_config
  end
  let(:filter) do
    described_class.new(config)
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource filter
    }.to_not raise_error
  end

  it 'should require a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should accept action allow' do
    filter[:action] = 'allow'
    expect(filter[:action]).to eq(:allow)
  end

  it 'should accept action deny' do
    filter[:action] = 'deny'
    expect(filter[:action]).to eq(:deny)
  end

  it 'should not accept invalid action' do
    expect {
      filter[:action] = 'foo'
    }.to raise_error(Puppet::Error)
  end

  defaults = {
    'namespace': 'default',
  }

  # String properties
  [
    :namespace,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 'foo'
      expect(filter[property]).to eq('foo')
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(filter[property]).to eq(default)
      end
    else
      it "should not have a default for #{property}" do
        expect(filter[property]).to eq(default_config[property])
      end
    end
  end

  # String regex validated properties
  [
    :name,
  ].each do |property|
    it "should not accept invalid #{property}" do
      config[property] = 'foo bar'
      expect { filter }.to raise_error(Puppet::Error, /#{property.to_s} invalid/)
    end
  end

  # Array properties
  [
    :expressions,
    :runtime_assets,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = ['foo', 'bar']
      expect(filter[property]).to eq(['foo', 'bar'])
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(filter[property]).to eq(default)
      end
    else
      it "should not have a default for #{property}" do
        expect(filter[property]).to eq(default_config[property])
      end
    end
  end

  # Integer properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 30
      expect(filter[property]).to eq(30)
    end
    it "should accept valid #{property} as string" do
      config[property] = '30'
      expect(filter[property]).to eq(30)
    end
    it "should not accept invalid value for #{property}" do
      config[property] = 'foo'
      expect { filter }.to raise_error(Puppet::Error, /should be an Integer/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(filter[property]).to eq(default)
      end
    else
      it "should not have a default for #{property}" do
        expect(filter[property]).to eq(default_config[property])
      end
    end
  end

  # Boolean properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = true
      expect(filter[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = false
      expect(filter[property]).to eq(:false)
    end
    it "should accept valid #{property}" do
      config[property] = 'true'
      expect(filter[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = 'false'
      expect(filter[property]).to eq(:false)
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { filter }.to raise_error(Puppet::Error, /Invalid value "foo". Valid values are true, false/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(filter[property]).to eq(default)
      end
    else
      it "should not have a default for #{property}" do
        expect(filter[property]).to eq(default_config[property])
      end
    end
  end

  # Hash properties
  [
    :labels,
    :annotations,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = { 'foo': 'bar' }
      expect(filter[property]).to eq({'foo': 'bar'})
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { filter }.to raise_error(Puppet::Error, /should be a Hash/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(filter[property]).to eq(default)
      end
    else
      it "should not have a default for #{property}" do
        expect(filter[property]).to eq(default_config[property])
      end
    end
  end

  it 'should autorequire Package[sensu-go-cli]' do
    package = Puppet::Type.type(:package).new(:name => 'sensu-go-cli')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource filter
    catalog.add_resource package
    rel = filter.autorequire[0]
    expect(rel.source.ref).to eq(package.ref)
    expect(rel.target.ref).to eq(filter.ref)
  end

  it 'should autorequire Service[sensu-backend]' do
    service = Puppet::Type.type(:service).new(:name => 'sensu-backend')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource filter
    catalog.add_resource service
    rel = filter.autorequire[0]
    expect(rel.source.ref).to eq(service.ref)
    expect(rel.target.ref).to eq(filter.ref)
  end

  it 'should autorequire Exec[sensuctl_configure]' do
    exec = Puppet::Type.type(:exec).new(:name => 'sensuctl_configure', :command => '/usr/bin/sensuctl')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource filter
    catalog.add_resource exec
    rel = filter.autorequire[0]
    expect(rel.source.ref).to eq(exec.ref)
    expect(rel.target.ref).to eq(filter.ref)
  end

  it 'should autorequire sensu_api_validator' do
    validator = Puppet::Type.type(:sensu_api_validator).new(:name => 'sensu')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource filter
    catalog.add_resource validator
    rel = filter.autorequire[0]
    expect(rel.source.ref).to eq(validator.ref)
    expect(rel.target.ref).to eq(filter.ref)
  end

  [
    :action,
    :expressions,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { filter }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end
end
