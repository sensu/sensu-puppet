require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_extension).provide(:json) do
  confine :feature => :json

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
    conf[resource[:name]] = {}
    self.config = resource[:config]
  end

  def config_file
    "#{resource[:base_path]}/#{resource[:name]}.json"
  end

  def destroy
    conf.delete resource[:name]
  end

  def exists?
    conf.has_key? resource[:name]
  end

  def config
    conf[resource[:name]]
  end

  def config=(value)
    conf[resource[:name]] = value
  end
end
