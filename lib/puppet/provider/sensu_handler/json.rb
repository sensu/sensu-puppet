require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_handler).provide(:json) do
  confine :feature => :json

  def initialize(*args)
    super

    begin
      @conf = JSON.parse(File.read("/etc/sensu/conf.d/handlers/#{resource[:name]}.json"))
    rescue
      @conf = {}
    end
  end

  def flush
    File.open("/etc/sensu/conf.d/handlers/#{resource[:name]}.json", 'w') do |f|
      f.puts JSON.pretty_generate(@conf)
    end
  end

  def create
    @conf['handlers'] = {}
    @conf['handlers'][resource[:name]] = {}
    self.command = resource[:command]
    self.type = resource[:type]
    # Optional arguments
    self.config = resource[:config] unless resource[:config].nil?
    self.exchange = resource[:exchange] unless resource[:exchange].nil?
    self.handlers = resource[:handlers] unless resource[:handlers].nil?
    self.mutator = resource[:mutator] unless resource[:mutator].nil?
    self.severities = resource[:severities] unless resource[:severities].nil?
  end

  def destroy
    @conf = nil
  end

  def exists?
    @conf.has_key?('handlers') and @conf['handlers'].has_key?(resource[:name])
  end

  def command
    @conf['handlers'][resource[:name]]['command']
  end

  def command=(value)
    @conf['handlers'][resource[:name]]['command'] = value
  end

  def config
    @conf[resource[:name]]
  end

  def config=(value)
    @conf[resource[:name]] = value
  end

  def exchange
    @conf['handlers'][resource[:name]]['exchange']
  end

  def exchange=(value)
    @conf['handlers'][resource[:name]]['exchange'] = value
  end

  def handlers
    @conf['handlers'][resource[:name]]['handlers']
  end

  def handlers=(value)
    @conf['handlers'][resource[:name]]['handlers'] = value
  end

  def mutator
    @conf['handlers'][resource[:name]]['mutator']
  end

  def mutator=(value)
    @conf['handlers'][resource[:name]]['mutator'] = value
  end

  def severities
    @conf['handlers'][resource[:name]]['severities']
  end

  def severities=(value)
    @conf['handlers'][resource[:name]]['severities'] = value
  end

  def type
    @conf['handlers'][resource[:name]]['type']
  end

  def type=(value)
    @conf['handlers'][resource[:name]]['type'] = value
  end
end
