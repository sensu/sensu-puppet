require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_check).provide(:json) do
  confine :feature => :json

  def initialize(*args)
    super

    @conf = nil
  end

  def conf
    begin
      @conf ||= JSON.parse(File.read("/etc/sensu/conf.d/checks/#{resource[:name]}.json"))
    rescue
      @conf ||= {}
    end
  end

  def flush
    File.open("/etc/sensu/conf.d/checks/#{resource[:name]}.json", 'w') do |f|
      f.puts JSON.pretty_generate(conf)
    end
  end

  def create
    conf['checks'] = {}
    conf['checks'][resource[:name]] = {}
    self.handlers = resource[:handlers]
    self.command = resource[:command]
    self.interval = resource[:interval]
    self.subscribers = resource[:subscribers]
    # Optional arguments
    self.sla = resource[:sla] unless resource[:sla].nil?
    self.type = resource[:type] unless resource[:type].nil?
    self.config = resource[:config] unless resource[:config].nil?
    self.aggregate = resource[:aggregate] unless resource[:aggregate].nil?
    self.standalone = resource[:standalone] unless resource[:standalone].nil?
    self.high_flap_threshold = resource[:high_flap_threshold] unless resource[:high_flap_threshold].nil?
    self.low_flap_threshold = resource[:low_flap_threshold] unless resource[:low_flap_threshold].nil?
    self.occurrences = resource[:occurrences] unless resource[:occurrences].nil?
    self.refresh = resource[:refresh] unless resource[:refresh].nil?
    self.notification = resource[:notification] unless resource[:notification].nil?
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

  def interval=(value)
    conf['checks'][resource[:name]]['interval'] = value.to_i
  end

  def handlers
    conf['checks'][resource[:name]]['handlers'] || []
  end

  def handlers=(value)
    conf['checks'][resource[:name]]['handlers'] = value
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

  def command
    conf['checks'][resource[:name]]['command']
  end

  def command=(value)
    conf['checks'][resource[:name]]['command'] = value
  end

  def subscribers
    conf['checks'][resource[:name]]['subscribers'] || []
  end

  def subscribers=(value)
    conf['checks'][resource[:name]]['subscribers'] = value
  end

  def sla
    conf['checks'][resource[:name]]['sla'] || []
  end

  def sla=(value)
    conf['checks'][resource[:name]]['sla'] = value
  end

  def type
    conf['checks'][resource[:name]]['type']
  end

  def type=(value)
    conf['checks'][resource[:name]]['type'] = value
  end

  def config
    conf[resource[:name]]
  end

  def config=(value)
    conf[resource[:name]] = value
  end

  def notification
    conf['checks'][resource[:name]]['notification']
  end

  def notification=(value)
    conf['checks'][resource[:name]]['notification'] = value
  end

  def refresh
    conf['checks'][resource[:name]]['refresh'].to_s
  end

  def refresh=(value)
    conf['checks'][resource[:name]]['refresh'] = value.to_i
  end

  def occurrences
    conf['checks'][resource[:name]]['occurrences']
  end

  def occurrences=(value)
    conf['checks'][resource[:name]]['occurrences'] = value.to_i
  end

  def low_flap_threshold
    conf['checks'][resource[:name]]['low_flap_threshold']
  end

  def low_flap_threshold=(value)
    conf['checks'][resource[:name]]['low_flap_threshold'] = value.to_i
  end

  def high_flap_threshold
    conf['checks'][resource[:name]]['high_flap_threshold']
  end

  def high_flap_threshold=(value)
    conf['checks'][resource[:name]]['high_flap_threshold'] = value.to_i
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
