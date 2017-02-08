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
    # Clean nil valued properties, esp. sentinel related
    # Related to https://github.com/sensu/sensu-puppet/issues/394.
    self.class.resource_type.validproperties.each do |prop|
      if resource.should(prop).nil?
        conf['redis'].delete prop.to_s
      end
    end
    File.open(config_file, 'w') do |f|
      f.puts JSON.pretty_generate(conf)
    end
  end

  def pre_create
    conf['redis'] = {}
  end

  def config_file
    File.join(resource[:base_path], 'redis.json').gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
  end

  def destroy
    conf.delete 'redis'
  end

  def exists?
    conf.has_key? 'redis'
  end

  def port
    if conf['redis']['port'] then conf['redis']['port'].to_s else :absent end
  end

  def port=(value)
    if value == :absent
      conf['redis'].delete 'port'
    else
      conf['redis']['port'] = value.to_i
    end
  end

  def host
    conf['redis']['host'] || :absent
  end

  def host=(value)
    if value == :absent
      conf['redis'].delete 'host'
    else
      conf['redis']['host'] = value
    end
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

  def db
    conf['redis']['db'].to_s
  end

  def db=(value)
    conf['redis']['db'] = value.to_i
  end

  def sentinels
    conf['redis']['sentinels'] || []
  end

  def sentinels=(value)
    if value == []
      conf['redis'].delete 'sentinels'
    else
      conf['redis']['sentinels'] = value
    end
  end

  def master
    conf['redis']['master'] || :absent
  end

  def master=(value)
    if value == :absent
      conf['redis'].delete 'master'
    else
      conf['redis']['master'] = value.to_s
    end
  end

  def auto_reconnect
    conf['redis']['auto_reconnect']
  end

  def auto_reconnect=(value)
    conf['redis']['auto_reconnect'] = value
  end
end
