require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'provider_create.rb'))

Puppet::Type.type(:sensu_redis_sentinel_config).provide(:json) do
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
    File.join(resource[:base_path], 'redis.json').gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
  end

  def destroy
    conf.delete 'redis'
  end

  def exists?
    conf.has_key? 'redis'
  end

  def password
    conf['redis']['password']
  end

  def password=(value)
    conf['redis']['password'] = value
  end

  def sentinels
    conf['redis']['sentinels'] || []
  end

  def sentinels=(value)
    if value.is_a?(Array)
      arr = []
      value.each do |obj| 
        hash = {}
        obj.map do |k, v|
          if k == "port"
            hash[k] = v.to_i
          else
            hash[k] = v.to_s
          end
        end
        arr.push(hash)
      end
      conf['redis']['sentinels'] = arr
    else
      conf['redis']['sentinels'] = [ value ]
    end
  end

end
