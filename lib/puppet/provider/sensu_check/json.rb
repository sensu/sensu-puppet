require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?

begin
  require 'puppet_x/sensu/to_type'
rescue LoadError => e
  libdir = Pathname.new(__FILE__).parent.parent.parent.parent
  require File.join(libdir, 'puppet_x/sensu/to_type')
end

Puppet::Type.type(:sensu_check).provide(:json) do
  confine :feature => :json
  include Puppet_X::Sensu::Totype

  def initialize(*args)
    super

    @conf = nil
  end

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

  def create
    conf['checks'] = {}
    conf['checks'][resource[:name]] = {}
    self.command = resource[:command]
    self.interval = resource[:interval]
    # Optional arguments
    self.handlers = resource[:handlers] unless resource[:handlers].nil?
    self.subscribers = resource[:subscribers] unless resource[:subscribers].nil?
    self.type = resource[:type] unless resource[:type].nil?
    self.standalone = resource[:standalone] unless resource[:standalone].nil?
    self.high_flap_threshold = resource[:high_flap_threshold] unless resource[:high_flap_threshold].nil?
    self.low_flap_threshold = resource[:low_flap_threshold] unless resource[:low_flap_threshold].nil?
    self.timeout = resource[:timeout] unless resource[:timeout].nil?
    self.aggregate = resource[:aggregate] unless resource[:aggregate].nil?
    self.handle = resource[:handle] unless resource[:handle].nil?
    self.publish = resource[:publish] unless resource[:publish].nil?
    self.custom = resource[:custom] unless resource[:custom].nil?
  end

  def check_args
    ['handlers','command','interval','subscribers','type','standalone','high_flap_threshold','low_flap_threshold','timeout','aggregate','handle','publish','custom']
  end

  def custom
    conf['checks'][resource[:name]].reject { |k,v| check_args.include?(k) }
  end

  def custom=(value)
    conf['checks'][resource[:name]].delete_if { |k,v| not check_args.include?(k) }
    conf['checks'][resource[:name]].merge!(to_type(value))
  end

  def destroy
    conf = nil
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
    conf['checks'][resource[:name]]['handlers']
  end

  def handlers=(value)
    conf['checks'][resource[:name]]['handlers'] = value
  end

  def command
    conf['checks'][resource[:name]]['command']
  end

  def command=(value)
    conf['checks'][resource[:name]]['command'] = value
  end

  def dependencies
    conf['checks'][resource[:name]]['dependencies']
  end

  def dependencies=(value)
    value = [ value ] if value.is_a?(String)
    conf['checks'][resource[:name]]['dependencies'] = value
  end

  def subscribers
    conf['checks'][resource[:name]]['subscribers']
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
    case conf['checks'][resource[:name]]['aggregate']
    when true
      :true
    when false
      :false
    else
      conf['checks'][resource[:name]]['aggregate']
    end
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
    case conf['checks'][resource[:name]]['handle']
    when true
      :true
    when false
      :false
    else
      conf['checks'][resource[:name]]['handle']
    end
  end

  def handle=(value)
    case value
    when true, 'true', 'True', :true, 1
      conf['checks'][resource[:name]]['handle'] = true
    when false, 'false', 'False', :false, 0
      conf['checks'][resource[:name]]['handle'] = false
    else
      conf['checks'][resource[:name]]['handle'] = value
    end
  end

  def publish
    case conf['checks'][resource[:name]]['publish']
    when true
      :true
    when false
      :false
    else
      conf['checks'][resource[:name]]['publish']
    end
  end

  def publish=(value)
    case value
    when true, 'true', 'True', :true, 1
      conf['checks'][resource[:name]]['publish'] = true
    when false, 'false', 'False', :false, 0
      conf['checks'][resource[:name]]['publish'] = false
    else
      conf['checks'][resource[:name]]['publish'] = value
    end
  end

  def standalone
    case conf['checks'][resource[:name]]['standalone']
    when true
      :true
    when false
      :false
    else
      conf['checks'][resource[:name]]['standalone']
    end
  end

  def standalone=(value)
    case value
    when true, 'true', 'True', :true, 1
      conf['checks'][resource[:name]]['standalone'] = true
    when false, 'false', 'False', :false, 0
      conf['checks'][resource[:name]]['standalone'] = false
    else
      conf['checks'][resource[:name]]['standalone'] = value
    end
  end
end
