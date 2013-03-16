require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.features.rubygems?
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_check).provide(:json) do
  confine :feature => :json

  def initialize(*args)
    super

    @conf = nil
  end

  def conf
    resource[:realname] = resource[:name] if resource[:realname] == nil
    begin
      @conf ||= JSON.parse(File.read("/etc/sensu/conf.d/check_#{resource[:realname]}.json"))
    rescue
      @conf ||= {}
    end
  end

  def flush
    File.open("/etc/sensu/conf.d/check_#{resource[:realname]}.json", 'w') do |f|
      f.puts JSON.pretty_generate(conf)
    end
  end

  def create
    conf['checks'] = {}
    conf['checks'][resource[:realname]] = {}
    self.handlers = resource[:handlers]
    self.command = resource[:command]
    self.interval = resource[:interval]
    self.subscribers = resource[:subscribers]
    # Optional arguments
    self.type = resource[:type] unless resource[:type].nil?
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
    conf.has_key?('checks') and conf['checks'].has_key?(resource[:realname])
  end

  def interval
    conf['checks'][resource[:realname]]['interval'].to_s
  end

  def interval=(value)
    conf['checks'][resource[:realname]]['interval'] = value.to_i
  end

  def handlers
    conf['checks'][resource[:realname]]['handlers'] || []
  end

  def handlers=(value)
    conf['checks'][resource[:realname]]['handlers'] = value
  end

  def aggregate
    case conf['checks'][resource[:realname]]['aggregate']
    when true
      :true
    when false
      :false
    else
      conf['checks'][resource[:realname]]['aggregate']
    end
  end

  def aggregate=(value)
    case value
    when true, 'true', 'True', :true, 1
      conf['checks'][resource[:realname]]['aggregate'] = true
    when false, 'false', 'False', :false, 0
      conf['checks'][resource[:realname]]['aggregate'] = false
    else
      conf['checks'][resource[:realname]]['aggregate'] = value
    end
  end

  def command
    conf['checks'][resource[:realname]]['command']
  end

  def command=(value)
    conf['checks'][resource[:realname]]['command'] = value
  end

  def subscribers
    conf['checks'][resource[:realname]]['subscribers'] || []
  end

  def subscribers=(value)
    conf['checks'][resource[:realname]]['subscribers'] = value
  end

  def type
    conf['checks'][resource[:realname]]['type']
  end

  def type=(value)
    conf['checks'][resource[:realname]]['type'] = value
  end

  def notification
    conf['checks'][resource[:realname]]['notification']
  end

  def notification=(value)
    conf['checks'][resource[:realname]]['notification'] = value
  end

  def refresh
    conf['checks'][resource[:realname]]['refresh']
  end

  def refresh=(value)
    conf['checks'][resource[:realname]]['refresh'] = value
  end

  def occurrences
    conf['checks'][resource[:realname]]['occurrences']
  end

  def occurrences=(value)
    conf['checks'][resource[:realname]]['occurrences'] = value
  end

  def low_flap_threshold
    conf['checks'][resource[:realname]]['low_flap_threshold']
  end

  def low_flap_threshold=(value)
    conf['checks'][resource[:realname]]['low_flap_threshold'] = value.to_i
  end

  def high_flap_threshold
    conf['checks'][resource[:realname]]['high_flap_threshold']
  end

  def high_flap_threshold=(value)
    conf['checks'][resource[:realname]]['high_flap_threshold'] = value.to_i
  end

  def standalone
    case conf['checks'][resource[:realname]]['standalone']
    when true
      :true
    when false
      :false
    else
      conf['checks'][resource[:realname]]['standalone']
    end
  end

  def standalone=(value)
    case value
    when true, 'true', 'True', :true, 1
      conf['checks'][resource[:realname]]['standalone'] = true
    when false, 'false', 'False', :false, 0
      conf['checks'][resource[:realname]]['standalone'] = false
    else
      conf['checks'][resource[:realname]]['standalone'] = value
    end
  end
end
