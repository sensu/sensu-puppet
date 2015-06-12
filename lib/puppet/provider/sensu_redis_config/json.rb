begin
  require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
rescue
end
require 'json' if Puppet.features.json?
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'provider_create.rb'))

Puppet::Type.type(:sensu_redis_config).provide(:json) do
  confine :feature => :json
  include PuppetX::Sensu::ProviderCreate

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

  def pre_create
    conf['redis'] = {}
  end

  def config_file
    "#{resource[:base_path]}/redis.json"
  end

  def destroy
    conf.delete 'redis'
  end

  def exists?
    conf.has_key? 'redis'
  end

  def port
    conf['redis']['port'].to_s
  end

  def port=(value)
    conf['redis']['port'] = value.to_i
  end

  def host
    conf['redis']['host']
  end

  def host=(value)
    conf['redis']['host'] = value
  end

  def password
    conf['redis']['password']
  end

  def password=(value)
    conf['redis']['password'] = value
  end

  def reconnect_on_error
    conf['redis']['reconnect_on_error']
  end

  def reconnect_on_error=(value)
    conf['redis']['reconnect_on_error'] = value
  end
end
