require 'spec_helper'
require 'puppet/type/sensu_check'

describe Puppet::Type.type(:sensu_check) do
  let(:default_config) do
    {
      name: 'test',
      command: 'test',
      subscriptions: ['test'],
      handlers: ['test'],
    }
  end
  let(:config) do
    default_config
  end
  let(:check) do
    described_class.new(config)
  end

  it 'should add to catalog with raising an error' do
    catalog = Puppet::Resource::Catalog.new
    expect {
      catalog.add_resource check
    }.to_not raise_error
  end

  it 'should require a name' do
    expect {
      described_class.new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  defaults = {
    'organization': 'default',
    'environment': 'default',
  }

  # String properties
  [
    :command,
    :cron,
    :proxy_entity_id,
    :metric_format,
    :output_metric_format
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 'foo'
      expect(check[property]).to eq('foo')
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(check[property]).to eq(default)
      end
    end
  end

  # String regex validated properties
  [
    :name,
    :proxy_entity_id
  ].each do |property|
    it "should not accept invalid #{property}" do
      config[property] = 'foo bar'
      expect { check }.to raise_error(Puppet::Error, /#{property.to_s} invalid/)
    end
  end

  # Array properties
  [
    :subscriptions,
    :handlers,
    :runtime_assets,
    :proxy_requests_entity_attributes,
    :metric_handlers,
    :output_metric_handlers,
    :env_vars
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = ['foo', 'bar']
      expect(check[property]).to eq(['foo', 'bar'])
    end
  end

  # Integer properties
  [
    :interval,
    :timeout,
    :ttl,
    :low_flap_threshold,
    :high_flap_threshold,
    :proxy_requests_splay_coverage,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = 30
      expect(check[property]).to eq(30)
    end
    it "should accept valid #{property} as string" do
      config[property] = '30'
      expect(check[property]).to eq(30)
    end
    it "should not accept invalid value for #{property}" do
      config[property] = 'foo'
      expect { check }.to raise_error(Puppet::Error, /should be an Integer/)
    end
  end

  # Boolean properties
  [
    :publish,
    :stdin,
    :round_robin,
    :proxy_requests_splay,
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = true
      expect(check[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = false
      expect(check[property]).to eq(:false)
    end
    it "should accept valid #{property}" do
      config[property] = 'true'
      expect(check[property]).to eq(:true)
    end
    it "should accept valid #{property}" do
      config[property] = 'false'
      expect(check[property]).to eq(:false)
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { check }.to raise_error(Puppet::Error, /Invalid value "foo". Valid values are true, false/)
    end
  end

  # Hash properties
  [
    :extended_attributes
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = { 'foo': 'bar' }
      expect(check[property]).to eq({'foo': 'bar'})
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { check }.to raise_error(Puppet::Error, /should be a Hash/)
    end
  end

  describe 'subdue_days' do
    it 'accepts valid value for when' do
      config[:subdue_days] = {'all' => [{'begin' => '5:00 PM', 'end' => '8:00 AM'}]}
      expect(check[:subdue_days]).to eq({'all' => [{'begin' => '5:00 PM', 'end' => '8:00 AM'}]})
    end

    it "should not accept invalid value" do
      config[:subdue_days] = 'foo'
      expect { check }.to raise_error(Puppet::Error, /should be a Hash/)
    end

    it 'should handle invalid day' do
      config[:subdue_days] = {'foo' => [{'begin' => '5:00 PM', 'end' => '8:00 AM'}]}
      expect { check }.to raise_error(Puppet::Error, /subdue_days keys must be day of the week or 'all'/)
    end

    it 'should require day key to be array' do
      config[:subdue_days] = {'all' => 'foo'}
      expect { check }.to raise_error(Puppet::Error, /subdue_days hash values must be an Array/)
    end

    it 'should verify time range is hash' do
      config[:subdue_days] = {'all' => ['foo']}
      expect { check }.to raise_error(Puppet::Error, /subdue_days day time window must be a hash containing keys 'begin' and 'end'/)
    end

    it 'should verify time range keys' do
      config[:subdue_days] = {'all' => [{'start' => '5:00 PM', 'end' => '8:00 AM'}]}
      expect { check }.to raise_error(Puppet::Error, /subdue_days day time window must be a hash containing keys 'begin' and 'end'/)
    end
  end

  describe 'check_hooks' do
    [
      1,
      '1',
      'ok',
      'warning',
      'critical',
      'unknown',
      'non-zero',
    ].each do |type|
      it "accepts valid values for type #{type} #{type.class}" do
        config[:check_hooks] = [{type => ['test']}]
        expect(check[:check_hooks]).to eq([{type => ['test']}])
      end
    end

    it 'should require Hash elements' do
      config[:check_hooks] = ['foo']
      expect { check }.to raise_error(Puppet::Error, /check_hooks elements must be a Hash/)
    end

    it 'should only allow one key' do
      config[:check_hooks] = [{'critical' => ['test'],'warning' => ['test']}]
      expect { check }.to raise_error(Puppet::Error, /check_hooks Hash must only contain one key/)
    end

    it 'should require valid type string' do
      config[:check_hooks] = [{'crit' => ['test']}]
      expect { check }.to raise_error(Puppet::Error, /check_hooks type value is invalid/)
    end

    it 'should require valid type integer' do
      config[:check_hooks] = [{'256' => ['test']}]
      expect { check }.to raise_error(Puppet::Error, /check_hooks type value is invalid/)
    end

    it 'should require hooks list to be an array' do
      config[:check_hooks] = [{'critical' => 'test'}]
      expect { check }.to raise_error(Puppet::Error, /check_hooks hooks must be an Array/)
    end
  end

  it 'should autorequire Package[sensu-cli]' do
    package = Puppet::Type.type(:package).new(:name => 'sensu-cli')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource check
    catalog.add_resource package
    rel = check.autorequire[0]
    expect(rel.source.ref).to eq(package.ref)
    expect(rel.target.ref).to eq(check.ref)
  end

  it 'should autorequire Service[sensu-backend]' do
    service = Puppet::Type.type(:service).new(:name => 'sensu-backend')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource check
    catalog.add_resource service
    rel = check.autorequire[0]
    expect(rel.source.ref).to eq(service.ref)
    expect(rel.target.ref).to eq(check.ref)
  end

  it 'should autorequire Exec[sensuctl_configure]' do
    exec = Puppet::Type.type(:exec).new(:name => 'sensuctl_configure', :command => '/usr/bin/sensuctl')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource check
    catalog.add_resource exec
    rel = check.autorequire[0]
    expect(rel.source.ref).to eq(exec.ref)
    expect(rel.target.ref).to eq(check.ref)
  end

  it 'should autorequire sensu_api_validator' do
    validator = Puppet::Type.type(:sensu_api_validator).new(:name => 'sensu')
    catalog = Puppet::Resource::Catalog.new
    catalog.add_resource check
    catalog.add_resource validator
    rel = check.autorequire[0]
    expect(rel.source.ref).to eq(validator.ref)
    expect(rel.target.ref).to eq(check.ref)
  end

  [
    :command,
    :subscriptions,
    :handlers
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { check }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end
end
