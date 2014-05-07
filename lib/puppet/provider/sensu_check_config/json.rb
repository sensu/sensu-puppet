require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_check_config).provide(:json) do
  confine :feature => :json

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
    if resource[:event]
      conf['checks'] = {}
      conf['checks'][resource[:name]] = {}
    end
    self.event = resource[:event] unless resource[:event].nil?
    self.config = resource[:config] unless resource[:config].nil?
  end

  def destroy
    conf = nil
  end

  def exists?
    if resource[:event] and resource[:config]
      conf.has_key?('checks') and conf['checks'].has_key?(resource[:name]) and conf.has_key?(resource[:name])
    else
      if resource[:event]
        conf.has_key?('checks') and conf['checks'].has_key?(resource[:name])
      end
      if resource[:config]
        conf.has_key?(resource[:name])
      end
    end
  end

  def config_file
    "#{resource[:base_path]}/config_#{resource[:name]}.json"
  end

  def config
    conf[resource[:name]] = resource[:config] || {}
  end

  def config=(value)
    conf[resource[:name]] = resource[:config]
  end

  def event
    conf['checks'][resource[:name]] = resource[:event] || {}
  end

  def event=(value)
    conf['checks'][resource[:name]] = resource[:event]
  end

end
