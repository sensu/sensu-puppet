require 'spec_helper'
require 'puppet/type/sensu_check'

describe Puppet::Type.type(:sensu_check) do
  let(:default_config) do
    {
      name: 'test',
      command: 'test',
      subscriptions: ['test'],
      handlers: ['test'],
      interval: 60,
    }
  end
  let(:config) do
    default_config
  end
  let(:check) do
    described_class.new(config)
  end

  it 'should add to catalog without raising an error' do
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

  include_examples 'name_regex' do
    let(:default_params) { default_config }
  end

  it 'should handle composite title' do
    config.delete(:namespace)
    config[:name] = 'test in dev'
    expect(check[:name]).to eq('test in dev')
    expect(check[:resource_name]).to eq('test')
    expect(check[:namespace]).to eq('dev')
  end

  it 'should handle non-composite title' do
    config[:name] = 'test'
    expect(check[:name]).to eq('test')
    expect(check[:resource_name]).to eq('test')
    expect(check[:namespace]).to eq('default')
  end

  it 'should handle composite title and namespace' do
    config[:namespace] = 'test'
    config[:name] = 'test in qa'
    expect(check[:resource_name]).to eq('test')
    expect(check[:namespace]).to eq('test')
  end

  it 'should handle invalid composites' do
    config[:name] = 'test test in qa'
    expect { check }.to raise_error(Puppet::Error, /name invalid/)
  end

  defaults = {
    'namespace': 'default',
    'publish': :true,
    'stdin': :false,
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
    else
      it "should not have default for #{property}" do
        expect(check[property]).to eq(default_config[property])
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
    :output_metric_handlers,
    :env_vars
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = ['foo', 'bar']
      expect(check[property]).to eq(['foo', 'bar'])
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(check[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(check[property]).to eq(default_config[property])
      end
    end
  end

  # Integer properties
  [
    :interval,
    :timeout,
    :low_flap_threshold,
    :high_flap_threshold,
    :max_output_size,
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
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(check[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(check[property]).to eq(default_config[property])
      end
    end
  end

  # Boolean properties
  [
    :publish,
    :stdin,
    :round_robin,
    :silenced,
    :discard_output,
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
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(check[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(check[property]).to eq(default_config[property])
      end
    end
  end

  # Hash properties
  [
  ].each do |property|
    it "should accept valid #{property}" do
      config[property] = { 'foo': 'bar' }
      expect(check[property]).to eq({'foo': 'bar'})
    end
    it "should not accept invalid #{property}" do
      config[property] = 'foo'
      expect { check }.to raise_error(Puppet::Error, /should be a Hash/)
    end
    if default = defaults[property]
      it "should have default for #{property}" do
        expect(check[property]).to eq(default)
      end
    else
      it "should not have default for #{property}" do
        expect(check[property]).to eq(default_config[property])
      end
    end
  end

  describe 'interval and cron' do
    it 'should be required' do
      config[:publish] = true
      config.delete(:interval)
      config.delete(:cron)
      expect { check.pre_run_check }.to raise_error(Puppet::Error, /interval or cron is required/)
    end
    it 'should not be required if publish is false' do
      config[:publish] = false
      config.delete(:interval)
      config.delete(:cron)
      expect { check }.not_to raise_error
    end
    it 'interval should not be required if cron is defined' do
      config[:cron] = '0 0 * * *'
      config.delete(:interval)
      expect { check }.not_to raise_error
    end
    it 'cron should not be required if interval is defined' do
      config[:interval] = 60
      config.delete(:cron)
      expect { check }.not_to raise_error
    end
  end

  describe 'ttl' do
    it 'should accept value' do
      config[:interval] = 60
      config[:ttl] = 120
      expect(check[:ttl]).to eq(120)
    end
    it 'should accept string value' do
      config[:interval] = 60
      config[:ttl] = '120'
      expect(check[:ttl]).to eq(120)
    end
    it 'should not accept invalid value' do
      config[:ttl] = 'foo'
      expect { check }.to raise_error(Puppet::Error, /should be an Integer/)
    end
    it 'should be greater than interval' do
      config[:interval] = 60
      config[:ttl] = 30
      expect { check.pre_run_check }.to raise_error(Puppet::Error, /check ttl 30 must be greater than interval 60/)
    end
  end

  describe 'check_hooks' do
    [
      0,
      '0',
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
        expect(check[:check_hooks]).to eq([{type.to_s => ['test']}])
      end
    end

    it 'should not have default' do
      expect(check[:check_hooks]).to be_nil
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
      'prometheus_text',
    ].each do |v|
      it "should accept #{v}" do
        config[:output_metric_format] = v
        expect(check[:output_metric_format]).to eq(v.to_sym)
      end
    end

    it 'should not have a default' do
      expect(check[:output_metric_format]).to be_nil
    end

    it 'should not accept invalid values' do
      config[:output_metric_format] = 'foo'
      expect { check }.to raise_error(Puppet::Error, /Invalid value "foo". Valid values are nagios_perfdata, graphite_plaintext, influxdb_line, opentsdb_line, prometheus_text, absent/)
    end
  end

  describe 'output_metric_tags' do
    it 'should accept a valid value' do
      config[:output_metric_tags] = [{'name' => 'instance', 'value' => '{{ .name }}'}]
      expect(check[:output_metric_tags]).to eq([{'name' => 'instance', 'value' => '{{ .name }}'}])
    end
    it 'requires hash for each tag' do
      config[:output_metric_tags] = ['foo']
      expect { check }.to raise_error(Puppet::Error, /must be a Hash/)
    end
    it 'requires valid keys for tag' do
      config[:output_metric_tags] = [{'name' => 'instance'}]
      expect { check }.to raise_error(Puppet::Error, /tag must contain/)
    end
    it 'requires strings for values' do
      config[:output_metric_tags] = [{'name' => 'instance', 'value' => false}]
      expect { check }.to raise_error(Puppet::Error, /must be a String/)
    end
  end

  describe 'proxy_requests' do
    it 'accepts valid value' do
      config[:proxy_requests] = {'entity_attributes' => ['foo==bar'],'splay' => true, 'splay_coverage' => 60}
      expect(check[:proxy_requests]).to eq({'entity_attributes' => ['foo==bar'],'splay' => true, 'splay_coverage' => 60})
    end
    it 'requires a hash' do
      config[:proxy_requests] = 'foo'
      expect { check }.to raise_error(Puppet::Error, /should be a Hash/)
    end
    it 'does not accept invalid key' do
      config[:proxy_requests] = {'foo' => 'bar'}
      expect { check }.to raise_error(Puppet::Error, /foo is not a valid key for proxy_requests/)
    end
    it 'requires array for entity_attributes' do
      config[:proxy_requests] = {'entity_attributes' => 'foo==bar','splay' => true, 'splay_coverage' => 60}
      expect { check }.to raise_error(Puppet::Error, /must be an Array/)
    end
    it 'requires boolean for splay' do
      config[:proxy_requests] = {'entity_attributes' => ['foo==bar'],'splay' => 'foo', 'splay_coverage' => 60}
      expect { check }.to raise_error(Puppet::Error, /must be a Boolean/)
    end
    it 'requires integer for splay_coverage' do
      config[:proxy_requests] = {'entity_attributes' => ['foo==bar'],'splay' => true, 'splay_coverage' => 'foo'}
      expect { check }.to raise_error(Puppet::Error, /must be an Integer/)
    end
  end

  include_examples 'secrets property' do
    let(:res) { check }
  end

  include_examples 'autorequires' do
    let(:res) { check }
  end

  it 'should autorequire sensu_handler' do
    handler = Puppet::Type.type(:sensu_handler).new(:name => 'test', :type => 'pipe', :command => 'test')
    catalog = Puppet::Resource::Catalog.new
    config[:handlers] = ['test']
    catalog.add_resource check
    catalog.add_resource handler
    rel = check.autorequire[0]
    expect(rel.source.ref).to eq(handler.ref)
    expect(rel.target.ref).to eq(check.ref)
  end

  it 'should autorequire sensu_asset' do
    asset = Puppet::Type.type(:sensu_asset).new(:name => 'test', :builds => [{'url' => 'http://example.com/asset/example.tar', 'sha512' => '4f926bf4328fbad2b9cac873d117f771914f4b837c9c85584c38ccf55a3ef3c2e8d154812246e5dda4a87450576b2c58ad9ab40c9e2edc31b288d066b195b21b'}])
    catalog = Puppet::Resource::Catalog.new
    config[:runtime_assets] = ['test']
    catalog.add_resource check
    catalog.add_resource asset
    rel = check.autorequire[0]
    expect(rel.source.ref).to eq(asset.ref)
    expect(rel.target.ref).to eq(check.ref)
  end

  it 'should autorequire sensu_hook' do
    hook = Puppet::Type.type(:sensu_hook).new(:name => 'test', :command => 'test')
    catalog = Puppet::Resource::Catalog.new
    config[:check_hooks] = [{1 => ['test']},{'critical' => ['test2']}]
    catalog.add_resource check
    catalog.add_resource hook
    rel = check.autorequire[0]
    expect(rel.source.ref).to eq(hook.ref)
    expect(rel.target.ref).to eq(check.ref)
  end

  [
    :command,
    :subscriptions,
  ].each do |property|
    it "should require property when ensure => present" do
      config.delete(property)
      config[:ensure] = :present
      expect { check.pre_run_check }.to raise_error(Puppet::Error, /You must provide a #{property}/)
    end
  end

  include_examples 'namespace' do
    let(:res) { check }
  end
  include_examples 'labels' do
    let(:res) { check }
  end
  include_examples 'annotations' do
    let(:res) { check }
  end
end
