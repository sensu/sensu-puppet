require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_redis_config).provide(:json) do
  confine :feature => :json

  def conf
    begin
      @conf ||= JSON.parse(File.read('/etc/sensu/conf.d/redis.json'))
    rescue
      @conf ||= {}
    end
  end

  def flush
    File.open('/etc/sensu/conf.d/redis.json', 'w') do |f|
      f.puts JSON.pretty_generate(conf)
    end
  end

  def create
    conf['redis'] = {}
    self.port = resource[:port]
    self.host = resource[:host]
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
end
