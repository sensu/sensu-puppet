require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'json'

Puppet::Type.type(:sensu_handler_config).provide(:json) do
  def initialize(*args)
    super

    begin
      @conf = JSON.parse(File.read("/etc/sensu/conf.d/handlers_#{resource[:name]}.json"))
    rescue
      @conf = {}
    end
  end

  def flush
    File.open("/etc/sensu/conf.d/handlers_#{resource[:name]}.json", 'w') do |f|
      f.puts JSON.pretty_generate(@conf)
    end
  end

  def create
    @conf['handlers'] = {}
    @conf['handlers'][resource[:name]] = {}
    self.command = resource[:command]
    self.type = resource[:type]
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

  def type
    @conf['handlers'][resource[:name]]['type']
  end

  def type=(value)
    @conf['handlers'][resource[:name]]['type'] = value
  end
end
