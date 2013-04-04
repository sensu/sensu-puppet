require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.features.rubygems?
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_check_config).provide(:json) do
  confine :feature => :json

  def initialize(*args)
    super

    @conf = nil
  end

  def conf
    begin
      @conf ||= JSON.parse(File.read("/etc/sensu/conf.d/checks/config_#{resource[:name]}.json"))
    rescue
      @conf ||= {}
    end
  end

  def flush
    File.open("/etc/sensu/conf.d/checks/config_#{resource[:name]}.json", 'w') do |f|
      f.puts JSON.pretty_generate(conf)
    end
  end

  def create
    if resource.has_key?(:event)
      conf['checks'] = {}
      conf['checks'][resource[:name]] = {}
    end
  end

  def destroy
    conf = nil
  end

  def exists?
    conf.has_key?(resource[:name]) or conf.has_key?('checks')
  end

  def config=(value)
    conf[resource[:name]] = resource[:config]
  end

  def event=(value)
    conf['checks'][resource[:name]] = resource[:event]
  end

end
