require 'spec_helper'
require 'puppet/type/sensu_role'

describe Puppet::Type.type(:sensu_role) do
  let(:default_config) do
    {
      name: 'test',
      rules: [{'verbs' => ['get','list'], 'resources' => ['checks']}]
    }
  end
  let(:config) do
    default_config
  end
  let(:role) do
    described_class.new(config)
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource role
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
    expect(role[:name]).to eq('test in dev')
    expect(role[:resource_name]).to eq('test')
    expect(role[:namespace]).to eq('dev')
  end

  it 'should handle non-composite title' do
    config[:name] = 'test'
    expect(role[:name]).to eq('test')
    expect(role[:resource_name]).to eq('test')
    expect(role[:namespace]).to eq('default')
  end

  it 'should handle composite title and namespace' do
    config[:namespace] = 'test'
    config[:name] = 'test in qa'
    expect(role[:resource_name]).to eq('test')
    expect(role[:namespace]).to eq('test')
  end

  it 'should handle invalid composites' do
    config[:name] = 'test test in qa'
    expect { role }.to raise_error(Puppet::Error, /name invalid/)
  end

  defaults = {
    :namespace => 'default',
  }

  # String properties
  [
    :namespace,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 'foo'
      expect(role[property]).to eq('foo')
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(role[property]).to eq(default)
      end
    end
  end

  # String regex validated properties
  [
  ].each do |property|
    it "should not accept invalid #{property}" do
      config[property] = 'foo bar'
      expect { role }.to raise_error(Puppet::Error, /#{property.to_s} invalid/)
    end
  end

  # Array properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = ['foo', 'bar']
      expect(role[property]).to eq(['foo', 'bar'])
    end
  end

  # Integer properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 30
      expect(role[property]).to eq(30)
    end
    it "should accept valid #{property} as string" do
      config[property] = '30'
      expect(role[property]).to eq(30)
    end
    it "should not accept invalid value for #{property}" do
      config[property] = 'foo'
      expect { role }.to raise_error(Puppet::Error, /should be an Integer/)
    end
  end

  # Boolean properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = true
      expect(role[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = false
      expect(role[property]).to eq(:false)
    end
    it "should accept valid #{property}" do
      config[property] = 'true'
      expect(role[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = 'false'
      expect(role[property]).to eq(:false)
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { role }.to raise_error(Puppet::Error, /Invalid value "foo". Valid values are true, false/)
    end
  end

  # Hash properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = { 'foo': 'bar' }
      expect(role[property]).to eq({'foo': 'bar'})
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { role }.to raise_error(Puppet::Error, /should be a Hash/)
    end
  end

  describe 'rules' do
    it 'has valid value' do
      expect(role[:rules]).to eq([{'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => nil}])
    end

    it 'accepts valid value' do
      config[:rules] = [{'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => ['test']}]
      expect(role[:rules]).to eq([{'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => ['test']}])
    end

    it 'should verify rule is a hash' do
      config[:rules] = ['foo']
      expect { role }.to raise_error(Puppet::Error, /Each rule must be a Hash/)
    end

    it 'should verify all keys present' do
      config[:rules] = [{'verbs' => ['get','list']}]
      expect { role }. to raise_error(Puppet::Error, /A rule must contain resources/)
    end

    it 'should not allow unknown keys' do
      config[:rules] = [{'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => [''], 'foo' => 'bar'}]
      expect { role }. to raise_error(Puppet::Error, /Rule key foo is not valid/)
    end

    it 'should verify permissions is an array' do
      config[:rules] = [{'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => ''}]
      expect { role }. to raise_error(Puppet::Error, /Rule's resource_names must be an Array/)
    end
  end

  include_examples 'autorequires' do
    let(:res) { role }
  end

  [
    :rules,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { role.pre_run_check }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end

  include_examples 'namespace' do
    let(:res) { role }
  end
end
