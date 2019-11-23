require 'spec_helper'
require 'puppet/type/sensu_command'

describe Puppet::Type.type(:sensu_command) do
  let(:default_config) do
    {
      name: 'command-test',
      bonsai_name: 'sensu/command-test',
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

  defaults = {}

  # String properties
  [
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

  describe 'bonsai_version' do
    it 'should allow latest' do
      config[:bonsai_version] = 'latest'
      expect(resource[:bonsai_version]).to eq(:latest)
    end
    it 'should allow a bonsai_version' do
      config[:bonsai_version] = '1.0.0'
      expect(resource[:bonsai_version]).to eq('1.0.0')
    end
    it 'should raise error if not latest or bonsai_version' do
      config[:bonsai_version] = 'foo'
      expect { resource }.to raise_error(Puppet::Error, /Invalid value/)
    end
    it 'should be in sync' do
      config[:bonsai_version] = '1.0.0'
      expect(resource.property(:bonsai_version).insync?('1.0.0')).to eq(true)
    end
    it 'should not be in sync' do
      config[:bonsai_version] = '1.1.0'
      expect(resource.property(:bonsai_version).insync?('1.0.0')).to eq(false)
      expect(resource.property(:bonsai_version).should_to_s('1.1.0')).to eq("'1.1.0'")
    end
    it 'should be in sync with latest' do
      config[:provider] = 'sensuctl'
      allow(Puppet::Type::Sensu_command::ProviderSensuctl).to receive(:latest_bonsai_version).and_return('1.1.0')
      config[:bonsai_version] = 'latest'
      expect(resource.property(:bonsai_version).insync?('1.1.0')).to eq(true)
    end
    it 'should not be in sync with latest' do
      config[:provider] = 'sensuctl'
      allow(Puppet::Type::Sensu_command::ProviderSensuctl).to receive(:latest_bonsai_version).and_return('1.1.0')
      config[:bonsai_version] = 'latest'
      expect(resource.property(:bonsai_version).insync?('1.0.0')).to eq(false)
      expect(resource.property(:bonsai_version).should_to_s('latest')).to eq("'1.1.0'")
    end
  end

  include_examples 'autorequires', false do
    let(:res) { resource }
  end

  describe 'validations' do
    before(:each) do
      config[:ensure] = 'present'
    end

    it 'should require bonsai_name or url' do
      config.delete(:bonsai_name)
      config.delete(:url)
      expect { resource }.to raise_error(/bonsai_name or url/)
    end
    it 'should not allow bonsai_name and url' do
      config[:bonsai_name] = 'sensu/command-test'
      config[:url] = 'https://foo.example.com/command-test.tar.gz'
      expect { resource }.to raise_error(/bonsai_name and url are mutually exclusive/)
    end
    it 'requires sha512 with url' do
      config.delete(:sha512)
      config.delete(:bonsai_name)
      config[:url] = 'https://foo.example.com/command-test.tar.gz'
      expect { resource }.to raise_error(/sha512 is required/)
    end
  end

  [
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { resource }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end
end
