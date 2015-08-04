require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_default_handler).provide(:json) do
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
      f.puts JSON.pretty_generate(@conf)
    end
  end

  def create
    unless conf.has_key?('handlers')
      conf['handlers'] = {}
    end

    unless conf['handlers'].has_key?('default')
      conf['handlers']['default'] = {}
    end

    unless conf['handlers']['default'].has_key?('type')
      conf['handlers']['default']['type'] = 'set'
    end

    unless conf['handlers']['default'].has_key?('handlers')
      conf['handlers']['default']['handlers'] = []
    end

    conf['handlers']['default']['handlers'].push resource[:name]
  end

  def destroy
    unless
        !conf.nil? &&
        conf.has_key?('handlers') &&
        conf['handlers'].has_key?('default') &&
        conf['handlers']['default'].has_key?('handlers')
      return false
    end
    conf['handlers']['default']['handlers'].delete resource[:name]
  end

  def exists?
    unless
        !conf.nil? &&
        conf.has_key?('handlers') &&
        conf['handlers'].has_key?('default') &&
        conf['handlers']['default'].has_key?('handlers')
      return false
    end
    conf['handlers']['default']['handlers'].include? resource[:name]
  end

  def config_file
    "#{resource[:base_path]}/default_handler.json"
  end
end
