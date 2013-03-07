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
    conf['checks'][resource[:realname]]['aggregate']
  end

  def aggregate=(value)
    conf['checks'][resource[:realname]]['aggregate'] = value
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
    conf['checks'][resource[:realname]]['standalone']
  end

  def standalone=(value)
    conf['checks'][resource[:realname]]['standalone'] = value
  end
end
