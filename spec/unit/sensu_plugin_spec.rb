require 'spec_helper'
require 'puppet/type/sensu_plugin'

describe Puppet::Type.type(:sensu_plugin) do
  let(:default_config) do
    {
      name: 'test',
    }
  end
  let(:config) do
    default_config
  end
  let(:plugin) do
    described_class.new(config)
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource plugin
    }.to_not raise_error
  end

  it 'should require a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should munge name when includes sensu-plugins-' do
    config[:name] = 'sensu-plugins-disk-plugins'
    expect(plugin[:name]).to eq('disk-plugins')
  end

  it 'should munge name when includes sensu-extensions-' do
    config[:name] = 'sensu-extensions-foo'
    expect(plugin[:name]).to eq('foo')
  end

  defaults = {
    'extension': :false,
    'clean': :true,
  }

  # String properties
  [
    :source,
    :proxy,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 'foo'
      expect(plugin[property]).to eq('foo')
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(plugin[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(plugin[property]).to eq(default_config[property])
      end
    end
  end

  # String regex validated properties
  [
  ].each do |property|
    it "should not accept invalid #{property}" do
      config[property] = 'foo bar'
      expect { plugin }.to raise_error(Puppet::Error, /#{property.to_s} invalid/)
    end
  end

  # Array properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = ['foo', 'bar']
      expect(plugin[property]).to eq(['foo', 'bar'])
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(plugin[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(plugin[property]).to eq(default_config[property])
      end
    end
  end

  # Integer properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 30
      expect(plugin[property]).to eq(30)
    end
    it "should accept valid #{property} as string" do
      config[property] = '30'
      expect(plugin[property]).to eq(30)
    end
    it "should not accept invalid value for #{property}" do
      config[property] = 'foo'
      expect { plugin }.to raise_error(Puppet::Error, /should be an Integer/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(plugin[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(plugin[property]).to eq(default_config[property])
      end
    end
  end

  # Boolean properties
  [
    :extension,
    :clean,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = true
      expect(plugin[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = false
      expect(plugin[property]).to eq(:false)
    end
    it "should accept valid #{property}" do
      config[property] = 'true'
      expect(plugin[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = 'false'
      expect(plugin[property]).to eq(:false)
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { plugin }.to raise_error(Puppet::Error, /Invalid value "foo". Valid values are true, false/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(plugin[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(plugin[property]).to eq(default_config[property])
      end
    end
  end

  # Hash properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = { 'foo': 'bar' }
      expect(plugin[property]).to eq({'foo': 'bar'})
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { plugin }.to raise_error(Puppet::Error, /should be a Hash/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(plugin[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(plugin[property]).to eq(default_config[property])
      end
    end
  end

  describe 'version' do
    it 'should allow latest' do
      config[:version] = 'latest'
      expect(plugin[:version]).to eq(:latest)
    end
    it 'should allow a version' do
      config[:version] = '1.0.0'
      expect(plugin[:version]).to eq('1.0.0')
    end
    it 'should raise error if not latest or version' do
      config[:version] = 'foo'
      expect { plugin }.to raise_error(Puppet::Error, /Invalid value/)
    end
    it 'should be in sync' do
      config[:version] = '1.0.0'
      expect(plugin.property(:version).insync?('1.0.0')).to eq(true)
    end
    it 'should not be in sync' do
      config[:version] = '1.1.0'
      expect(plugin.property(:version).insync?('1.0.0')).to eq(false)
      expect(plugin.property(:version).should_to_s('1.1.0')).to eq("'1.1.0'")
    end
    it 'should be in sync with latest' do
      config[:provider] = 'sensu_install'
      allow(Puppet::Type::Sensu_plugin::ProviderSensu_install).to receive(:latest_versions).and_return({config[:name] => '1.1.0', 'foo' => '1.2.0'})
      config[:version] = 'latest'
      expect(plugin.property(:version).insync?('1.1.0')).to eq(true)
    end
    it 'should not be in sync with latest' do
      config[:provider] = 'sensu_install'
      allow(Puppet::Type::Sensu_plugin::ProviderSensu_install).to receive(:latest_versions).and_return({config[:name] => '1.1.0', 'foo' => '1.2.0'})
      config[:version] = 'latest'
      expect(plugin.property(:version).insync?('1.0.0')).to eq(false)
      expect(plugin.property(:version).should_to_s('latest')).to eq("'1.1.0'")
    end
  end

  it 'should autorequire sensu-plugins-ruby' do
    package = Puppet::Type.type(:package).new(:name => 'sensu-plugins-ruby')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource plugin
    catalog.add_resource package
    rel = plugin.autorequire[0]
    expect(rel.source.ref).to eq(package.ref)
    expect(rel.target.ref).to eq(plugin.ref)
  end

  [
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { plugin }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end
end
