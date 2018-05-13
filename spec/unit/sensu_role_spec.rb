require 'spec_helper'
require 'puppet/type/sensu_role'

describe Puppet::Type.type(:sensu_role) do
  let(:default_config) do
    {
      name: 'test',
      rules: [{'type' => '*', 'environment' => '*', 'organization' => '*', 'permissions' => ['read']}]
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

  defaults = {
  }

  # String properties
  [
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
    :name,
  ].each do |property|
    it "should not accept invalid #{property}" do
      config[property] = 'foo bar'
      expect { role }.to raise_error(Puppet::Error)
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
      expect { role }.to raise_error(Puppet::Error)
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
    it 'accepts valid value' do
      expect(role[:rules]).to eq([{'type' => '*', 'environment' => '*', 'organization' => '*', 'permissions' => ['read']}])
    end

    it 'should verify rule is a hash' do
      config[:rules] = ['foo']
      expect { role }.to raise_error(Puppet::Error, /Each rule must be a Hash/)
    end

    it 'should verify all keys present' do
      config[:rules] = [{'type' => '*', 'environment' => '*', 'organization' => '*'}]
      expect { role }. to raise_error(Puppet::Error, /A rule must contain permissions/)
    end

    it 'should not allow unknown keys' do
      config[:rules] = [{'type' => '*', 'environment' => '*', 'organization' => '*', 'permissions' => ['read'], 'foo' => 'bar'}]
      expect { role }. to raise_error(Puppet::Error, /Rule key foo is not valid/)
    end

    it 'should verify permissions is an array' do
      config[:rules] = [{'type' => '*', 'environment' => '*', 'organization' => '*', 'permissions' => 'read'}]
      expect { role }. to raise_error(Puppet::Error, /A rule's permissions must be an array/)
    end
  end

  it 'should autorequire Package[sensu-cli]' do
    package = Puppet::Type.type(:package).new(:name => 'sensu-cli')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource role
    catalog.add_resource package
    rel = role.autorequire[0]
    expect(rel.source.ref).to eq(package.ref)
    expect(rel.target.ref).to eq(role.ref)
  end

  it 'should autorequire Service[sensu-backend]' do
    service = Puppet::Type.type(:service).new(:name => 'sensu-backend')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource role
    catalog.add_resource service
    rel = role.autorequire[0]
    expect(rel.source.ref).to eq(service.ref)
    expect(rel.target.ref).to eq(role.ref)
  end

  it 'should autorequire Exec[sensuctl_configure]' do
    exec = Puppet::Type.type(:exec).new(:name => 'sensuctl_configure', :command => '/usr/bin/sensuctl')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource role
    catalog.add_resource exec
    rel = role.autorequire[0]
    expect(rel.source.ref).to eq(exec.ref)
    expect(rel.target.ref).to eq(role.ref)
  end

  it 'should autorequire sensu_api_validator' do
    validator = Puppet::Type.type(:sensu_api_validator).new(:name => 'sensu')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource role
    catalog.add_resource validator
    rel = role.autorequire[0]
    expect(rel.source.ref).to eq(validator.ref)
    expect(rel.target.ref).to eq(role.ref)
  end

  [
    :rules,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { role }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end
end
