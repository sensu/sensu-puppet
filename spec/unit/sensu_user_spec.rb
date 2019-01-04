require 'spec_helper'
require 'puppet/type/sensu_user'

describe Puppet::Type.type(:sensu_user) do
  let(:default_config) do
    {
      name: 'test',
      password: 'foobar',
    }
  end
  let(:config) do
    default_config
  end
  let(:user) do
    described_class.new(config)
  end

  it 'should add to catalog without raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource user
    }.to_not raise_error
  end

  it 'should require a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not accept ensure => absent' do
    config[:ensure] = 'absent'
    expect { user[:ensure] = 'absent' }.to raise_error(Puppet::Error, /ensure does not support absent/)
  end

  defaults = {
    'disabled': :false,
    'configure': :false,
    'configure_url': 'http://127.0.0.1:8080',
  }

  # String properties
  [
    :password,
    :old_password,
    :configure_url
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 'foo'
      expect(user[property]).to eq('foo')
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(user[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(user[property]).to eq(default_config[property])
      end
    end
  end

  # String regex validated properties
  [
  ].each do |property|
    it "should not accept invalid #{property}" do
      config[property] = 'foo bar'
      expect { user }.to raise_error(Puppet::Error)
    end
  end

  # Array properties
  [
    :groups,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = ['foo', 'bar']
      expect(user[property]).to eq(['foo', 'bar'])
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(user[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(user[property]).to eq(default_config[property])
      end
    end
  end

  # Integer properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 30
      expect(user[property]).to eq(30)
    end
    it "should accept valid #{property} as string" do
      config[property] = '30'
      expect(user[property]).to eq(30)
    end
    it "should not accept invalid value for #{property}" do
      config[property] = 'foo'
      expect { user }.to raise_error(Puppet::Error, /should be an Integer/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(user[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(user[property]).to eq(default_config[property])
      end
    end
  end

  # Boolean properties
  [
    :disabled,
    :configure
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = true
      expect(user[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = false
      expect(user[property]).to eq(:false)
    end
    it "should accept valid #{property}" do
      config[property] = 'true'
      expect(user[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = 'false'
      expect(user[property]).to eq(:false)
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { user }.to raise_error(Puppet::Error)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(user[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(user[property]).to eq(default_config[property])
      end
    end
  end

  # Hash properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = { 'foo': 'bar' }
      expect(user[property]).to eq({'foo': 'bar'})
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { user }.to raise_error(Puppet::Error, /should be a Hash/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(user[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(user[property]).to eq(default_config[property])
      end
    end
  end

  include_examples 'autorequires', false do
    let(:res) { user }
  end

  [
    :password,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { user }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end
end
