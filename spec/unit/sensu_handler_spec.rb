require 'spec_helper'
require 'puppet/type/sensu_handler'

describe Puppet::Type.type(:sensu_handler) do
  let(:default_config) do
    {
      name: 'test',
      type: 'pipe',
      command: 'test',
      socket_host: '127.0.0.1',
      socket_port: 9000,
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
    'organization': 'default',
    'environment': 'default',
  }

  # String properties
  [
    :mutator,
    :command,
    :organization,
    :environment,
    :socket_host,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 'foo'
      expect(handler[property]).to eq('foo')
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(handler[property]).to eq(default)
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
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = ['foo', 'bar']
      expect(handler[property]).to eq(['foo', 'bar'])
    end
  end

  # Integer properties
  [
    :timeout,
    :socket_port,
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
  end

  it 'should autorequire Package[sensu-cli]' do
    package = Puppet::Type.type(:package).new(:name => 'sensu-cli')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource handler
    catalog.add_resource package
    rel = handler.autorequire[0]
    expect(rel.source.ref).to eq(package.ref)
    expect(rel.target.ref).to eq(handler.ref)
  end

  it 'should autorequire Service[sensu-backend]' do
    service = Puppet::Type.type(:service).new(:name => 'sensu-backend')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource handler
    catalog.add_resource service
    rel = handler.autorequire[0]
    expect(rel.source.ref).to eq(service.ref)
    expect(rel.target.ref).to eq(handler.ref)
  end

  it 'should autorequire Exec[sensuctl_configure]' do
    exec = Puppet::Type.type(:exec).new(:name => 'sensuctl_configure', :command => '/usr/bin/sensuctl')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource handler
    catalog.add_resource exec
    rel = handler.autorequire[0]
    expect(rel.source.ref).to eq(exec.ref)
    expect(rel.target.ref).to eq(handler.ref)
  end

  it 'should autorequire sensu_api_validator' do
    validator = Puppet::Type.type(:sensu_api_validator).new(:name => 'sensu')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource handler
    catalog.add_resource validator
    rel = handler.autorequire[0]
    expect(rel.source.ref).to eq(validator.ref)
    expect(rel.target.ref).to eq(handler.ref)
  end

  [
    :type,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { handler }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end

  it 'should require command for type pipe' do
    config.delete(:command)
    expect { handler }.to raise_error(Puppet::Error, /command must be defined for type pipe/)
  end

  it 'should require socket_host and socket_port' do
    config.delete(:socket_port)
    expect { handler }.to raise_error(Puppet::Error, /socket_port is required if socket_host is set/)
  end
  it 'should require socket_host and socket_port' do
    config.delete(:socket_host)
    expect { handler }.to raise_error(Puppet::Error, /socket_host is required if socket_port is set/)
  end
  it 'should require socket properties for tcp type' do
    config.delete(:socket_host)
    config.delete(:socket_port)
    config[:type] = :tcp
    expect { handler }.to raise_error(Puppet::Error, /socket_host and socket_port are required for type tcp or type udp/)
  end
  it 'should require socket properties for udp type' do
    config.delete(:socket_host)
    config.delete(:socket_port)
    config[:type] = :udp
    expect { handler }.to raise_error(Puppet::Error, /socket_host and socket_port are required for type tcp or type udp/)
  end
end
