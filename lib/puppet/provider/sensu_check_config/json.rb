require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'json'

Puppet::Type.type(:sensu_check_config).provide(:json) do
  def initialize(*args)
    super

    @conf = nil
  end

  def conf
    begin
      @conf ||= JSON.parse(File.read("/etc/sensu/conf.d/checks_#{resource[:realname]}.json"))
    rescue
      @conf ||= {}
    end
  end

  def flush
    File.open("/etc/sensu/conf.d/checks_#{resource[:realname]}.json", 'w') do |f|
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
end
