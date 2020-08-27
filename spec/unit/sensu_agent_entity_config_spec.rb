require 'spec_helper'
require 'puppet/type/sensu_agent_entity_config'

describe Puppet::Type.type(:sensu_agent_entity_config) do
  let(:default_config) do
    {
      name: 'subscriptions',
      entity: 'agent',
      value: 'linux',
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

  it 'should handle composite title' do
    config.delete(:config)
    config.delete(:namespace)
    config.delete(:entity)
    config.delete(:value)
    config[:name] = 'subscriptions value linux on agent in dev'
    expect(resource[:name]).to eq('subscriptions value linux on agent in dev')
    expect(resource[:config]).to eq('subscriptions')
    expect(resource[:entity]).to eq('agent')
    expect(resource[:namespace]).to eq('dev')
    expect(resource[:value]).to eq('linux')
  end

  it 'should handle composite title with key' do
    config.delete(:config)
    config.delete(:key)
    config.delete(:namespace)
    config.delete(:entity)
    config[:name] = 'annotations key contacts on agent in dev'
    expect(resource[:name]).to eq('annotations key contacts on agent in dev')
    expect(resource[:config]).to eq('annotations')
    expect(resource[:key]).to eq('contacts')
    expect(resource[:entity]).to eq('agent')
    expect(resource[:namespace]).to eq('dev')
  end

  it 'should handle non-composite title' do
    config[:name] = 'subscriptions'
    config[:entity] = 'agent'
    expect(resource[:name]).to eq('subscriptions')
    expect(resource[:config]).to eq('subscriptions')
    expect(resource[:entity]).to eq('agent')
    expect(resource[:namespace]).to eq('default')
  end

  it 'should handle composite title and namespace' do
    config[:namespace] = 'test'
    config[:name] = 'subscriptions value test on agent in qa'
    expect(resource[:config]).to eq('subscriptions')
    expect(resource[:namespace]).to eq('test')
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

  include_examples 'autorequires' do
    let(:res) { resource }
  end

  it 'should autorequire Service[sensu-agent]' do
    service = Puppet::Type.type(:service).new(:name => 'sensu-agent')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource service
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(service.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  it 'should autorequire sensu_agent_entity_validator' do
    validator = Puppet::Type.type(:sensu_agent_entity_validator).new(:name => 'agent')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource resource
    catalog.add_resource validator
    rel = resource.autorequire[0]
    expect(rel.source.ref).to eq(validator.ref)
    expect(rel.target.ref).to eq(resource.ref)
  end

  context 'validations' do
    describe 'entity' do
      it 'requires entity when present' do
        config.delete(:entity)
        config[:ensure] = :present
        expect { resource.pre_run_check }.to raise_error(Puppet::Error, %r{entity})
      end
      it 'requires entity when absent' do
        config.delete(:entity)
        config[:ensure] = :absent
        expect { resource.pre_run_check }.to raise_error(Puppet::Error, %r{entity})
      end
    end
    describe 'value' do
      it 'requires value when present' do
        config.delete(:value)
        config[:ensure] = :present
        config[:config] = 'subscriptions'
        expect { resource.pre_run_check }.to raise_error(Puppet::Error, %r{value property})
      end
      it 'requires value when absent' do
        config.delete(:value)
        config[:ensure] = :absent
        config[:config] = 'subscriptions'
        expect { resource.pre_run_check }.to raise_error(Puppet::Error, %r{value property})
      end
    end
    describe 'key' do
      it 'requires key when present' do
        config.delete(:key)
        config[:ensure] = :present
        config[:config] = 'labels'
        expect { resource.pre_run_check }.to raise_error(Puppet::Error, %r{key})
      end
      it 'requires key when absent' do
        config.delete(:key)
        config[:ensure] = :absent
        config[:config] = 'labels'
        expect { resource.pre_run_check }.to raise_error(Puppet::Error, %r{key})
      end
    end
  end

  include_examples 'namespace' do
    let(:res) { resource }
  end
end
