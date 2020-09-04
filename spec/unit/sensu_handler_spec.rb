require 'spec_helper'
require 'puppet/type/sensu_handler'

describe Puppet::Type.type(:sensu_handler) do
  let(:default_config) do
    {
      name: 'test',
      type: 'pipe',
      command: 'test',
      socket: {'host' => '127.0.0.1', 'port' => 9000},
    }
  end
  let(:config) do
    default_config
  end
  let(:handler) do
    described_class.new(config)
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource handler
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
    expect(handler[:name]).to eq('test in dev')
    expect(handler[:resource_name]).to eq('test')
    expect(handler[:namespace]).to eq('dev')
  end

  it 'should handle non-composite title' do
    config[:name] = 'test'
    expect(handler[:name]).to eq('test')
    expect(handler[:resource_name]).to eq('test')
    expect(handler[:namespace]).to eq('default')
  end

  it 'should handle composite title and namespace' do
    config[:namespace] = 'test'
    config[:name] = 'test in qa'
    expect(handler[:resource_name]).to eq('test')
    expect(handler[:namespace]).to eq('test')
  end

  it 'should handle invalid composites' do
    config[:name] = 'test test in qa'
    expect { handler }.to raise_error(Puppet::Error, /name invalid/)
  end

  it 'should accept type' do
    handler[:type] = 'tcp'
    expect(handler[:type]).to eq(:tcp)
  end

  it 'should not accept invalid type' do
    expect {
      handler[:type] = 'foo'
    }.to raise_error(Puppet::Error, /Invalid value "foo". Valid values are pipe, tcp, udp, set./)
  end

  defaults = {
    'namespace': 'default',
  }

  # String properties
  [
    :mutator,
    :command,
    :namespace,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 'foo'
      expect(handler[property]).to eq('foo')
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(handler[property]).to eq(default)
      end
    else
      it "should not have a default for #{property}" do
        expect(handler[property]).to eq(default_config[property])
      end
    end
  end

  # String regex validated properties
  [
    :name,
  ].each do |property|
    it "should not accept invalid #{property}" do
      config[property] = 'foo bar'
      expect { handler }.to raise_error(Puppet::Error, /#{property.to_s} invalid/)
    end
  end

  # Array properties
  [
    :filters,
    :env_vars,
    :handlers,
    :runtime_assets,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = ['foo', 'bar']
      expect(handler[property]).to eq(['foo', 'bar'])
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(handler[property]).to eq(default)
      end
    else
      it "should not have a default for #{property}" do
        expect(handler[property]).to eq(default_config[property])
      end
    end
  end

  # Integer properties
  [
    :timeout,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 30
      expect(handler[property]).to eq(30)
    end
    it "should accept valid #{property} as string" do
      config[property] = '30'
      expect(handler[property]).to eq(30)
    end
    it "should not accept invalid value for #{property}" do
      config[property] = 'foo'
      expect { handler }.to raise_error(Puppet::Error, /should be an Integer/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(handler[property]).to eq(default)
      end
    else
      it "should not have a default for #{property}" do
        expect(handler[property]).to eq(default_config[property])
      end
    end
  end

  # Boolean properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = true
      expect(handler[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = false
      expect(handler[property]).to eq(:false)
    end
    it "should accept valid #{property}" do
      config[property] = 'true'
      expect(handler[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = 'false'
      expect(handler[property]).to eq(:false)
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { handler }.to raise_error(Puppet::Error, /Invalid value "foo". Valid values are true, false/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(handler[property]).to eq(default)
      end
    else
      it "should not have a default for #{property}" do
        expect(handler[property]).to eq(default_config[property])
      end
    end
  end

  # Hash properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = { 'foo': 'bar' }
      expect(handler[property]).to eq({'foo': 'bar'})
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { handler }.to raise_error(Puppet::Error, /should be a Hash/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(handler[property]).to eq(default)
      end
    else
      it "should not have a default for #{property}" do
        expect(handler[property]).to eq(default_config[property])
      end
    end
  end

  describe 'timeout' do
    it 'should have default for tcp type' do
      config[:type] = 'tcp'
      config.delete(:timeout)
      expect(handler[:timeout]).to eq(60)
    end
    it 'should not have default without tcp type' do
      config[:type] = 'pipe'
      expect(handler[:timeout]).to be_nil
    end
  end

  describe 'socket' do
    it 'accepts valid value' do
      expect(handler[:socket]).to eq({'host' => '127.0.0.1', 'port' => 9000})
    end
    it 'requires a hash' do
      config[:socket] = 'foo'
      expect { handler }.to raise_error(Puppet::Error, /should be a Hash/)
    end
    it 'does not accept invalid key' do
      config[:socket] = {'host' => '127.0.0.1', 'port' => 9000, 'foo' => 'bar'}
      expect { handler }.to raise_error(Puppet::Error, /foo is not a valid key for socket/)
    end
    it 'requires host' do
      config[:socket] = {'port' => 9000}
      expect { handler }.to raise_error(Puppet::Error, /is required for socket/)
    end
    it 'requires port' do
      config[:socket] = {'host' => '127.0.0.1'}
      expect { handler }.to raise_error(Puppet::Error, /is required for socket/)
    end
    it 'requires integer for port' do
      config[:socket] = {'host' => '127.0.0.1', 'port' => '9000'}
      expect { handler }.to raise_error(Puppet::Error, /must be an Integer/)
    end
  end

  include_examples 'secrets property' do
    let(:res) { handler }
  end

  include_examples 'autorequires' do
    let(:res) { handler }
  end

  it 'should autorequire sensu_filter' do
    filter = Puppet::Type.type(:sensu_filter).new(:name => 'test', :action => 'allow', :expressions => ['event.Check.Occurrences == 1'])
    catalog = Puppet::Resource::Catalog.new
    config[:filters] = ['test']
    catalog.add_resource handler
    catalog.add_resource filter
    rel = handler.autorequire[0]
    expect(rel.source.ref).to eq(filter.ref)
    expect(rel.target.ref).to eq(handler.ref)
  end

  it 'should autorequire sensu_mutator' do
    mutator = Puppet::Type.type(:sensu_mutator).new(:name => 'test', :command => 'test')
    catalog = Puppet::Resource::Catalog.new
    config[:mutator] = 'test'
    catalog.add_resource handler
    catalog.add_resource mutator
    rel = handler.autorequire[0]
    expect(rel.source.ref).to eq(mutator.ref)
    expect(rel.target.ref).to eq(handler.ref)
  end

  it 'should autorequire sensu_handler' do
    h = Puppet::Type.type(:sensu_handler).new(:name => 'test2', :type => 'pipe', :command => 'test')
    catalog = Puppet::Resource::Catalog.new
    config[:handlers] = ['test2']
    catalog.add_resource handler
    catalog.add_resource h
    rel = handler.autorequire[0]
    expect(rel.source.ref).to eq(h.ref)
    expect(rel.target.ref).to eq(handler.ref)
  end

  it 'should autorequire sensu_asset' do
    asset = Puppet::Type.type(:sensu_asset).new(:name => 'test', :builds => [{'url' => 'http://example.com/asset/example.tar', 'sha512' => '4f926bf4328fbad2b9cac873d117f771914f4b837c9c85584c38ccf55a3ef3c2e8d154812246e5dda4a87450576b2c58ad9ab40c9e2edc31b288d066b195b21b'}])
    catalog = Puppet::Resource::Catalog.new
    config[:runtime_assets] = ['test']
    catalog.add_resource handler
    catalog.add_resource asset
    rel = handler.autorequire[0]
    expect(rel.source.ref).to eq(asset.ref)
    expect(rel.target.ref).to eq(handler.ref)
  end

  [
    :type,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { handler.pre_run_check }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end

  it 'should require command for type pipe' do
    config.delete(:command)
    expect { handler.pre_run_check }.to raise_error(Puppet::Error, /command must be defined for type pipe/)
  end

  it 'should require socket for tcp type' do
    config.delete(:socket)
    config[:type] = :tcp
    expect { handler.pre_run_check }.to raise_error(Puppet::Error, /socket is required for type tcp or type udp/)
  end
  it 'should require socket for udp type' do
    config.delete(:socket)
    config[:type] = :udp
    expect { handler.pre_run_check }.to raise_error(Puppet::Error, /socket is required for type tcp or type udp/)
  end
  it 'should require handlers for type set' do
    config[:type] = 'set'
    config.delete(:handlers)
    expect { handler.pre_run_check }.to raise_error(Puppet::Error, /handlers must be defined for type set/)
  end

  include_examples 'namespace' do
    let(:res) { handler }
  end
  include_examples 'labels' do
    let(:res) { handler }
  end
  include_examples 'annotations' do
    let(:res) { handler }
  end
end
