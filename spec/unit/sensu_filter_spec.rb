require 'spec_helper'
require 'puppet/type/sensu_filter'

describe Puppet::Type.type(:sensu_filter) do
  let(:default_config) do
    {
      name: 'test',
      action: 'allow',
      expressions: ['event.check.occurrences == 1']
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

  include_examples 'name_regex' do
    let(:default_params) { default_config }
  end

  it 'should handle composite title' do
    config.delete(:namespace)
    config[:name] = 'test in dev'
    expect(filter[:name]).to eq('test in dev')
    expect(filter[:resource_name]).to eq('test')
    expect(filter[:namespace]).to eq('dev')
  end

  it 'should handle non-composite title' do
    config[:name] = 'test'
    expect(filter[:name]).to eq('test')
    expect(filter[:resource_name]).to eq('test')
    expect(filter[:namespace]).to eq('default')
  end

  it 'should handle composite title and namespace' do
    config[:namespace] = 'test'
    config[:name] = 'test in qa'
    expect(filter[:resource_name]).to eq('test')
    expect(filter[:namespace]).to eq('test')
  end

  it 'should handle invalid composites' do
    config[:name] = 'test test in qa'
    expect { filter }.to raise_error(Puppet::Error, /name invalid/)
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

  include_examples 'autorequires' do
    let(:res) { filter }
  end

  it 'should autorequire sensu_asset' do
    asset = Puppet::Type.type(:sensu_asset).new(:name => 'test', :builds => [{'url' => 'http://example.com/asset/example.tar', 'sha512' => '4f926bf4328fbad2b9cac873d117f771914f4b837c9c85584c38ccf55a3ef3c2e8d154812246e5dda4a87450576b2c58ad9ab40c9e2edc31b288d066b195b21b'}])
    catalog = Puppet::Resource::Catalog.new
    config[:runtime_assets] = ['test']
    catalog.add_resource filter
    catalog.add_resource asset
    rel = filter.autorequire[0]
    expect(rel.source.ref).to eq(asset.ref)
    expect(rel.target.ref).to eq(filter.ref)
  end

  [
    :action,
    :expressions,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { filter.pre_run_check }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end

  include_examples 'namespace' do
    let(:res) { filter }
  end
  include_examples 'labels' do
    let(:res) { filter }
  end
  include_examples 'annotations' do
    let(:res) { filter }
  end
end
