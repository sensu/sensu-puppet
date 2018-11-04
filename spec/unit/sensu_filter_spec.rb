require 'spec_helper'
require 'puppet/type/sensu_filter'

describe Puppet::Type.type(:sensu_filter) do
  let(:default_config) do
    {
      name: 'test',
      action: 'allow',
      statements: ['event.Check.Occurrences == 1']
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
    :statements,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = ['foo', 'bar']
      expect(filter[property]).to eq(['foo', 'bar'])
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
  end

  # Hash properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = { 'foo': 'bar' }
      expect(filter[property]).to eq({'foo': 'bar'})
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { filter }.to raise_error(Puppet::Error, /should be a Hash/)
    end
  end

  describe 'when_days' do
    it 'accepts valid value for when' do
      config[:when_days] = {'all' => [{'begin' => '5:00 PM', 'end' => '8:00 AM'}]}
      expect(filter[:when_days]).to eq({'all' => [{'begin' => '5:00 PM', 'end' => '8:00 AM'}]})
    end

    it 'should handle invalid day' do
      config[:when_days] = {'foo' => [{'begin' => '5:00 PM', 'end' => '8:00 AM'}]}
      expect { filter }.to raise_error(Puppet::Error, /when_days keys must be day of the week or 'all'/)
    end

    it 'should require day key to be array' do
      config[:when_days] = {'all' => 'foo'}
      expect { filter }.to raise_error(Puppet::Error, /when_days hash values must be an Array/)
    end

    it 'should verify time range is hash' do
      config[:when_days] = {'all' => ['foo']}
      expect { filter }.to raise_error(Puppet::Error, /when_days day time window must be a hash containing keys 'begin' and 'end'/)
    end

    it 'should verify time range keys' do
      config[:when_days] = {'all' => [{'start' => '5:00 PM', 'end' => '8:00 AM'}]}
      expect { filter }.to raise_error(Puppet::Error, /when_days day time window must be a hash containing keys 'begin' and 'end'/)
    end
  end

  it 'should autorequire Package[sensu-cli]' do
    package = Puppet::Type.type(:package).new(:name => 'sensu-cli')
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
    :statements,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { filter }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end
end
