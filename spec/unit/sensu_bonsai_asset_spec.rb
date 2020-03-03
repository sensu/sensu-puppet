require 'spec_helper'
require 'puppet/type/sensu_asset'

describe Puppet::Type.type(:sensu_bonsai_asset) do
  let(:default_config) do
    {
      name: 'sensu/sensu-pagerduty-handler',
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

  it 'should handle title pattern' do
    expect(asset[:bonsai_namespace]).to eq('sensu')
    expect(asset[:bonsai_name]).to eq('sensu-pagerduty-handler')
    expect(asset[:namespace]).to eq('default')
    expect(asset[:rename]).to eq('sensu/sensu-pagerduty-handler')
  end

  it 'should handle title pattern with namespace' do
    config[:name] = 'sensu/sensu-pagerduty-handler in dev'
    expect(asset[:bonsai_namespace]).to eq('sensu')
    expect(asset[:bonsai_name]).to eq('sensu-pagerduty-handler')
    expect(asset[:namespace]).to eq('dev')
    expect(asset[:rename]).to eq('sensu/sensu-pagerduty-handler')
  end

  it 'should have bonsai_namespace over composite name' do
    config[:bonsai_namespace] = 'sensu'
    config[:name] = 'foo/bar'
    expect(asset[:bonsai_namespace]).to eq('sensu')
    expect(asset[:bonsai_name]).to eq('bar')
    expect(asset[:name]).to eq('foo/bar')
    expect(asset[:rename]).to eq('sensu/bar')
  end

  it 'should have bonsai_name over composite name' do
    config[:bonsai_name] = 'baz'
    config[:name] = 'foo/bar'
    expect(asset[:bonsai_namespace]).to eq('foo')
    expect(asset[:bonsai_name]).to eq('baz')
    expect(asset[:name]).to eq('foo/bar')
    expect(asset[:rename]).to eq('foo/baz')
  end

  it 'should have namespace over composite name' do
    config[:name] = 'sensu/sensu-pagerduty-handler in dev'
    config[:namespace] = 'test'
    expect(asset[:name]).to eq('sensu/sensu-pagerduty-handler in dev')
    expect(asset[:namespace]).to eq('test')
    expect(asset[:rename]).to eq('sensu/sensu-pagerduty-handler')
  end

  defaults = {}

  # String properties
  [
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
  ].each do |property|
    it "should not accept invalid #{property}" do
      config[property] = 'foo bar'
      expect { asset }.to raise_error(Puppet::Error, /#{property.to_s} invalid/)
    end
  end

  # Array properties
  [
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

  describe 'version' do
    it 'should allow latest' do
      config[:version] = 'latest'
      expect(asset[:version]).to eq(:latest)
    end
    it 'should allow a version' do
      config[:version] = '1.0.0'
      expect(asset[:version]).to eq('1.0.0')
    end
    it 'should allow a version with v prefix' do
      config[:version] = 'v1.0.0'
      expect(asset[:version]).to eq('v1.0.0')
    end
    it 'should raise error if not latest or version' do
      config[:version] = 'foo'
      expect { asset }.to raise_error(Puppet::Error, /Invalid value/)
    end
    it 'should be in sync' do
      config[:version] = '1.0.0'
      expect(asset.property(:version).insync?('1.0.0')).to eq(true)
    end
    it 'should not be in sync' do
      config[:version] = '1.1.0'
      expect(asset.property(:version).insync?('1.0.0')).to eq(false)
      expect(asset.property(:version).should_to_s('1.1.0')).to eq("'1.1.0'")
    end
    it 'should be in sync with latest' do
      config[:provider] = 'sensuctl'
      allow(Puppet::Type::Sensu_bonsai_asset::ProviderSensuctl).to receive(:latest_version).and_return('1.1.0')
      config[:version] = 'latest'
      expect(asset.property(:version).insync?('1.1.0')).to eq(true)
    end
    it 'should not be in sync with latest' do
      config[:provider] = 'sensuctl'
      allow(Puppet::Type::Sensu_bonsai_asset::ProviderSensuctl).to receive(:latest_version).and_return('1.1.0')
      config[:version] = 'latest'
      expect(asset.property(:version).insync?('1.0.0')).to eq(false)
      expect(asset.property(:version).should_to_s('latest')).to eq("'1.1.0'")
    end
  end

  include_examples 'autorequires' do
    let(:res) { asset }
  end

  it 'should require bonsai_namespace' do
    config.delete(:bonsai_namespace)
    config[:bonsai_name] = 'foo'
    config[:name] = 'foo'
    expect { asset }.to raise_error(Puppet::Error, /bonsai_namespace/)
  end

  it 'should require bonsai_name' do
    config[:bonsai_namespace] = 'sensu'
    config.delete(:bonsai_name)
    config[:name] = 'foo'
    expect { asset }.to raise_error(Puppet::Error, /bonsai_name/)
  end

  [
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { asset }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end

  include_examples 'namespace' do
    let(:res) { asset }
  end
end
