require 'json'

Puppet::Type.type(:sensu_check_config).provide(:json) do
  def initialize(*args)
    super

    begin
      @conf = JSON.parse(File.read("/etc/sensu/conf.d/checks_#{resource[:name]}.json"))
    rescue
      @conf = {}
    end
  end

  def flush
    File.open("/etc/sensu/conf.d/checks_#{resource[:name]}.json", 'w') do |f|
      f.puts JSON.pretty_generate(@conf)
    end
  end

  def create
    @conf['checks'] = {}
    @conf['checks'][resource[:name]] = {}
    self.handlers = resource[:handlers]
    self.command = resource[:command]
    self.interval = resource[:interval]
    self.subscribers = resource[:subscribers]
  end

  def destroy
    @conf = nil
  end

  def exists?
    @conf.has_key?('checks') and @conf['checks'].has_key?(resource[:name])
  end

  def interval
    @conf['checks'][resource[:name]]['interval'].to_s
  end

  def interval=(value)
    @conf['checks'][resource[:name]]['interval'] = value.to_i
  end

  def handlers
    @conf['checks'][resource[:name]]['handlers'] || []
  end

  def handlers=(value)
    @conf['checks'][resource[:name]]['handlers'] = value
  end

  def command
    @conf['checks'][resource[:name]]['command']
  end

  def command=(value)
    @conf['checks'][resource[:name]]['command'] = value
  end

  def subscribers
    @conf['checks'][resource[:name]]['subscribers'] || []
  end

  def subscribers=(value)
    @conf['checks'][resource[:name]]['subscribers'] = value
  end
end
