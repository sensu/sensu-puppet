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
    'namespace': 'default',
  }

  # String properties
  [
    :command,
    :cron,
    :namespace,
    :proxy_entity_name,
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
    :proxy_entity_name,
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
    :labels,
    :annotations,
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
      expect { check }.to raise_error(Puppet::Error, /check_hooks type crit is invalid/)
    end

    it 'should require valid type integer' do
      config[:check_hooks] = [{'256' => ['test']}]
      expect { check }.to raise_error(Puppet::Error, /check_hooks type 256 is invalid/)
    end

    it 'should require hooks list to be an array' do
      config[:check_hooks] = [{'critical' => 'test'}]
      expect { check }.to raise_error(Puppet::Error, /check_hooks hooks must be an Array/)
    end
  end

  describe 'output_metric_format' do
    [
      'nagios_perfdata',
      'graphite_plaintext',
      'influxdb_line',
      'opentsdb_line',
    ].each do |v|
      it "should accept #{v}" do
        config[:output_metric_format] = v
        expect(check[:output_metric_format]).to eq(v.to_sym)
      end
    end

    it 'should not accept invalid values' do
      config[:output_metric_format] = 'foo'
      expect { check }.to raise_error(Puppet::Error, /Invalid value "foo". Valid values are nagios_perfdata, graphite_plaintext, influxdb_line, opentsdb_line, absent/)
    end
  end

  include_examples 'autorequires' do
    let(:res) { check }
  end

  [
    :command,
    :subscriptions,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { check }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end
end
