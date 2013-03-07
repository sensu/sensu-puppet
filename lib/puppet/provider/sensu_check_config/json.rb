require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.features.rubygems?
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_check_config).provide(:json) do
  confine :feature => :json

  def initialize(*args)
    super

    begin
      @conf = JSON.parse(File.read("/etc/sensu/conf.d/#{resource[:name]}.json"))
    rescue
      @conf = {}
    end
  end

  def flush
    File.open("/etc/sensu/conf.d/#{resource[:name]}.json", 'w') do |f|
      f.puts JSON.pretty_generate(@conf)
    end
  end

  def create
    @conf[resource[:name]] = {}
    self.config = resource[:config]
  end

  def destroy
    @conf = nil
  end

  def exists?
    @conf.has_key?(resource[:name])
  end

  def config
    @conf[resource[:name]]
  end

  def config=(value)
    @conf[resource[:name]] = value
  end
end
