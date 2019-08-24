require 'spec_helper'
require 'puppet/type/sensu_asset'

describe Puppet::Type.type(:sensu_asset) do
  let(:default_config) do
    {
      name: 'test',
      url: 'http://localhost',
      sha512: '0e3e75234abc68f4378a86b3f4b32a198ba301845b0cd6e50106e874345700cc6663a86c1ea125dc5e92be17c98f9a0f85ca9d5f595db2012f7cc3571945c123',
    }
  end
  let(:config) do
    default_config
  end
  let(:asset) do
    described_class.new(config)
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource asset
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
    expect(asset[:name]).to eq('test in dev')
    expect(asset[:resource_name]).to eq('test')
    expect(asset[:namespace]).to eq('dev')
  end

  it 'should handle non-composite title' do
    config[:name] = 'test'
    expect(asset[:name]).to eq('test')
    expect(asset[:resource_name]).to eq('test')
    expect(asset[:namespace]).to eq('default')
  end

  it 'should handle composite title and namespace' do
    config[:namespace] = 'test'
    config[:name] = 'test in qa'
    expect(asset[:resource_name]).to eq('test')
    expect(asset[:namespace]).to eq('test')
  end

  it 'should handle invalid composites' do
    config[:name] = 'test test in qa'
    expect { asset }.to raise_error(Puppet::Error, /name invalid/)
  end

  it 'should accept ensure => absent' do
    config[:ensure] = 'absent'
    expect(asset[:ensure]).to eq(:absent)
  end

  defaults = {
    'namespace': 'default',
  }

  # String properties
  [
    :url,
    :sha512,
    :namespace,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 'foo'
      expect(asset[property]).to eq('foo')
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(asset[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(asset[property]).to eq(default_config[property])
      end
    end
  end

  # String regex validated properties
  [
    :name,
  ].each do |property|
    it "should not accept invalid #{property}" do
      config[property] = 'foo bar'
      expect { asset }.to raise_error(Puppet::Error, /#{property.to_s} invalid/)
    end
  end

  # Array properties
  [
    :filters,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = ['foo', 'bar']
      expect(asset[property]).to eq(['foo', 'bar'])
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(asset[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(asset[property]).to eq(default_config[property])
      end
    end
  end

  # Integer properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 30
      expect(asset[property]).to eq(30)
    end
    it "should accept valid #{property} as string" do
      config[property] = '30'
      expect(asset[property]).to eq(30)
    end
    it "should not accept invalid value for #{property}" do
      config[property] = 'foo'
      expect { asset }.to raise_error(Puppet::Error, /should be an Integer/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(asset[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(asset[property]).to eq(default_config[property])
      end
    end
  end

  # Boolean properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = true
      expect(asset[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = false
      expect(asset[property]).to eq(:false)
    end
    it "should accept valid #{property}" do
      config[property] = 'true'
      expect(asset[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = 'false'
      expect(asset[property]).to eq(:false)
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { asset }.to raise_error(Puppet::Error, /Invalid value "foo". Valid values are true, false/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(asset[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(asset[property]).to eq(default_config[property])
      end
    end
  end

  # Hash properties
  [
    :headers,
    :labels,
    :annotations,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = { 'foo': 'bar' }
      expect(asset[property]).to eq({'foo': 'bar'})
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { asset }.to raise_error(Puppet::Error, /should be a Hash/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(asset[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(asset[property]).to eq(default_config[property])
      end
    end
  end

  include_examples 'autorequires' do
    let(:res) { asset }
  end

  [
    :url,
    :sha512,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { asset.pre_run_check }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end
end
