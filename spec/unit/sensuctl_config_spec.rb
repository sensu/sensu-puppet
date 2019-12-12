require 'spec_helper'
require 'puppet/type/sensuctl_config'

describe Puppet::Type.type(:sensuctl_config) do
  let(:default_config) do
    {name: 'sensu'}
  end
  let(:config) do
    default_config
  end
  let(:sensuctl_config) do
    described_class.new(config)
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource sensuctl_config
    }.to_not raise_error
  end

  it 'should require a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  defaults = {}

  # String properties
  [
    :path,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 'foo'
      expect(sensuctl_config[property]).to eq('foo')
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(sensuctl_config[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(sensuctl_config[property]).to eq(default_config[property])
      end
    end
  end

  # String regex validated properties
  [
  ].each do |property|
    it "should not accept invalid #{property}" do
      config[property] = 'foo bar'
      expect { sensuctl_config }.to raise_error(Puppet::Error, /#{property.to_s} invalid/)
    end
  end

  # Array properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = ['foo', 'bar']
      expect(sensuctl_config[property]).to eq(['foo', 'bar'])
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(sensuctl_config[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(sensuctl_config[property]).to eq(default_config[property])
      end
    end
  end

  # Integer properties
  [
    :chunk_size,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 30
      expect(sensuctl_config[property]).to eq(30)
    end
    it "should accept valid #{property} as string" do
      config[property] = '30'
      expect(sensuctl_config[property]).to eq(30)
    end
    it "should not accept invalid value for #{property}" do
      config[property] = 'foo'
      expect { sensuctl_config }.to raise_error(Puppet::Error, /should be an Integer/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(sensuctl_config[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(sensuctl_config[property]).to eq(default_config[property])
      end
    end
  end

  # Boolean properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = true
      expect(sensuctl_config[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = false
      expect(sensuctl_config[property]).to eq(:false)
    end
    it "should accept valid #{property}" do
      config[property] = 'true'
      expect(sensuctl_config[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = 'false'
      expect(sensuctl_config[property]).to eq(:false)
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { sensuctl_config }.to raise_error(Puppet::Error, /Invalid value "foo". Valid values are true, false/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(sensuctl_config[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(sensuctl_config[property]).to eq(default_config[property])
      end
    end
  end

  # Hash properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = { 'foo': 'bar' }
      expect(sensuctl_config[property]).to eq({'foo': 'bar'})
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { sensuctl_config }.to raise_error(Puppet::Error, /should be a Hash/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(sensuctl_config[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(sensuctl_config[property]).to eq(default_config[property])
      end
    end
  end

  describe 'generate' do
    before do
      sensuctl_config[:chunk_size] = 100
      sensuctl_config.generate
    end

    sensuctl_types.each do |type|
      it "should configure #{type} with chunk-size" do
        resource = Puppet::Type.type(type)
        provider_class = resource.provider(:sensuctl)
        expect(provider_class.chunk_size).to eq(100)
      end
    end
  end
end
