require 'spec_helper'
require 'puppet/type/sensu_user'

describe Puppet::Type.type(:sensu_user) do
  let(:default_config) do
    {
      name: 'test',
      password: 'password',
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

  valid_names = [
    'foo',
    'foo-bar',
    'foo.bar',
    'foo1',
    'fooBar',
    'foo_bar',
  ]
  invalid_names = [
    'foo!',
    'foo:',
  ]
  valid_names.each do |name|
    it "allows valid name #{name}" do
      config[:name] = name
      expect { user }.to_not raise_error
    end
  end
  invalid_names.each do |name|
    it "does not allow invalid name #{name}" do
      config[:name] = name
      expect { user }.to raise_error(/name/)
    end
  end

  it 'should not accept ensure => absent' do
    config[:ensure] = 'absent'
    expect { user[:ensure] = 'absent' }.to raise_error(Puppet::Error, /ensure does not support absent/)
  end

  defaults = {
    'disabled': :false,
    'configure': :false,
    'configure_url': 'http://127.0.0.1:8080',
    'configure_trusted_ca_file': '/etc/sensu/ssl/ca.crt',
  }

  # String properties
  [
    :configure_url,
    :configure_trusted_ca_file,
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

  describe 'password' do
    it 'accepts value' do
      expect(user[:password]).to eq('password')
    end
    it 'has minimum length' do
      config[:password] = 'foo'
      expect { user }.to raise_error(Puppet::Error, /8 characters long/)
    end
  end

  it 'should autorequire sensu_user' do
    validator = Puppet::Type.type(:sensu_user).new(:name => 'admin', :password => 'password')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource user
    catalog.add_resource validator
    rel = user.autorequire[0]
    expect(rel.source.ref).to eq(validator.ref)
    expect(rel.target.ref).to eq(user.ref)
  end

  include_examples 'autorequires', false, true, false do
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
