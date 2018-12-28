require 'spec_helper'
require 'puppet/type/sensu_silenced'

describe Puppet::Type.type(:sensu_silenced) do
  let(:default_config) do
    {
      name: 'entity:test:*',
    }
  end
  let(:config) do
    default_config
  end
  let(:silenced) do
    described_class.new(config)
  end

  it 'should add to catalog with raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource silenced
    }.to_not raise_error
  end

  it 'should require a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should handle composite title subscription' do
    expect(silenced[:subscription]).to eq('entity:test')
  end

  it 'should handle composite title check' do
    expect(silenced[:check]).to eq('*')
  end

  it 'should handle non-entity subscription composite name' do
    config[:name] = 'appserver:mysql_status'
    expect(silenced[:subscription]).to eq('appserver')
    expect(silenced[:check]).to eq('mysql_status')
  end

  defaults = {
    'namespace': 'default',
    'expire': -1,
  }

  # String properties
  [
    :check,
    :subscription,
    :creator,
    :reason,
    :namespace,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 'foo'
      expect(silenced[property]).to eq('foo')
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(silenced[property]).to eq(default)
      end
    end
  end

  # String regex validated properties
  [
  ].each do |property|
    it "should not accept invalid #{property}" do
      config[property] = 'foo bar'
      expect { silenced }.to raise_error(Puppet::Error, /#{property.to_s} invalid/)
    end
  end

  # Array properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = ['foo', 'bar']
      expect(silenced[property]).to eq(['foo', 'bar'])
    end
  end

  # Integer properties
  [
    :begin,
    :expire,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 30
      expect(silenced[property]).to eq(30)
    end
    it "should accept valid #{property} as string" do
      config[property] = '30'
      expect(silenced[property]).to eq(30)
    end
    it "should not accept invalid value for #{property}" do
      config[property] = 'foo'
      expect { silenced }.to raise_error(Puppet::Error, /should be an Integer/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(silenced[property]).to eq(default)
      end
    end
  end

  # Boolean properties
  [
    :expire_on_resolve,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = true
      expect(silenced[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = false
      expect(silenced[property]).to eq(:false)
    end
    it "should accept valid #{property}" do
      config[property] = 'true'
      expect(silenced[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = 'false'
      expect(silenced[property]).to eq(:false)
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { silenced }.to raise_error(Puppet::Error, /Invalid value "foo". Valid values are true, false/)
    end
  end

  # Hash properties
  [
    :labels,
    :annotations,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = { 'foo': 'bar' }
      expect(silenced[property]).to eq({'foo': 'bar'})
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { silenced }.to raise_error(Puppet::Error, /should be a Hash/)
    end
  end

  include_examples 'autorequires' do
    let(:res) { silenced }
  end

  [
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { silenced }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end

  it "should require check or subscription" do
    config[:name] = "test"
    expect { silenced }.to raise_error(Puppet::Error, /Must provide either check or subscription/)
  end
end
