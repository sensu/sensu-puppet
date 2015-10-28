require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'provider_create.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'to_type.rb'))

Puppet::Type.type(:sensu_check).provide(:json) do
  confine :feature => :json
  include PuppetX::Sensu::ToType
  include PuppetX::Sensu::ProviderCreate

  def conf
    begin
      @conf ||= JSON.parse(File.read(config_file))
    rescue
      @conf ||= {}
    end
  end

  def flush
    File.open(config_file, 'w') do |f|
      f.puts JSON.pretty_generate(conf)
    end
  end

  def pre_create
    conf['checks'] = {}
    conf['checks'][resource[:name]] = {}
  end

  def check_args
    ['handlers','command','interval','occurrences','refresh','source','subscribers','type','standalone','high_flap_threshold','low_flap_threshold','timeout','aggregate','handle','publish','dependencies','custom','ttl']
  end

  def custom
    conf['checks'][resource[:name]].reject { |k,v| check_args.include?(k) }
  end

  def custom=(value)
    conf['checks'][resource[:name]].delete_if { |k,v| not check_args.include?(k) }
    conf['checks'][resource[:name]].merge!(to_type(value))
  end

  def destroy
    @conf = nil
  end

  def exists?
    conf.has_key?('checks') and conf['checks'].has_key?(resource[:name])
  end

  def interval
    conf['checks'][resource[:name]]['interval'].to_s
  end

  def config_file
    "#{resource[:base_path]}/#{resource[:name]}.json"
  end

  def interval=(value)
    conf['checks'][resource[:name]]['interval'] = value.to_i
  end

  def handlers
    conf['checks'][resource[:name]]['handlers'] || []
  end

  def handlers=(value)
    conf['checks'][resource[:name]]['handlers'] = value
  end
  def occurrences
    conf['checks'][resource[:name]]['occurrences'].to_s
  end

  def occurrences=(value)
    conf['checks'][resource[:name]]['occurrences'] = value.to_i
  end

  def refresh
    conf['checks'][resource[:name]]['refresh'].to_s
  end

  def refresh=(value)
    conf['checks'][resource[:name]]['refresh'] = value.to_i
  end

  def command
    conf['checks'][resource[:name]]['command']
  end

  def command=(value)
    conf['checks'][resource[:name]]['command'] = value
  end

  def dependencies
    conf['checks'][resource[:name]]['dependencies'] || []
  end

  def dependencies=(value)
    value = [ value ] if value.is_a?(String)
    conf['checks'][resource[:name]]['dependencies'] = value
  end

  def subscribers
    conf['checks'][resource[:name]]['subscribers'] || []
  end

  def subscribers=(value)
    conf['checks'][resource[:name]]['subscribers'] = value
  end

  def type
    conf['checks'][resource[:name]]['type']
  end

  def type=(value)
    conf['checks'][resource[:name]]['type'] = value
  end

  def low_flap_threshold
    conf['checks'][resource[:name]]['low_flap_threshold'].to_s
  end

  def low_flap_threshold=(value)
    conf['checks'][resource[:name]]['low_flap_threshold'] = value.to_i
  end

  def high_flap_threshold
    conf['checks'][resource[:name]]['high_flap_threshold'].to_s
  end

  def high_flap_threshold=(value)
    conf['checks'][resource[:name]]['high_flap_threshold'] = value.to_i
  end

  def source
    conf['checks'][resource[:name]]['source']
  end

  def source=(value)
    conf['checks'][resource[:name]]['source'] = value
  end

  def timeout
    conf['checks'][resource[:name]]['timeout'].to_s
  end

  def trim num
    i, f = num.to_i, num.to_f
    i == f ? i : f
  end

  def timeout=(value)
    conf['checks'][resource[:name]]['timeout'] = trim(value)
  end

  def aggregate
    conf['checks'][resource[:name]]['aggregate']
  end

  def aggregate=(value)
    case value
    when true, 'true', 'True', :true, 1
      conf['checks'][resource[:name]]['aggregate'] = true
    when false, 'false', 'False', :false, 0
      conf['checks'][resource[:name]]['aggregate'] = false
    else
      conf['checks'][resource[:name]]['aggregate'] = value
    end
  end

  def handle
    conf['checks'][resource[:name]]['handle']
  end

  def handle=(value)
    conf['checks'][resource[:name]]['handle'] = value
  end

  def publish
    conf['checks'][resource[:name]]['publish']
  end

  def publish=(value)
    conf['checks'][resource[:name]]['publish'] = value
  end

  def standalone
    conf['checks'][resource[:name]]['standalone']
  end

  def standalone=(value)
    conf['checks'][resource[:name]]['standalone'] = value
  end

  def ttl
    conf['checks'][resource[:name]]['ttl'].to_s
  end

  def ttl=(value)
    conf['checks'][resource[:name]]['ttl'] = value.to_i
  end

  def subdue
    conf['checks'][resource[:name]]['subdue']
  end

  def subdue=(value)
    conf['checks'][resource[:name]]['subdue'] = value
  end
end
