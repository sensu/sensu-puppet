require 'json' if Puppet.features.json?
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'provider_create.rb'))

Puppet::Type.type(:sensu_rabbitmq_config).provide(:json) do
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
    conf['rabbitmq'] = {}
  end

  def destroy
    conf.delete 'rabbitmq'
  end

  def exists?
    conf.has_key? 'rabbitmq'
  end

  def ssl_transport
    if conf['rabbitmq'].class != Array
      if conf['rabbitmq'].has_key? 'ssl'
        :true
      else
        :false
      end
    else
      :false
    end
  end

  def ssl_transport=(value)
    if value == :false
      if conf['rabbitmq'].has_key? 'ssl'
        conf['rabbitmq'].delete 'ssl' if conf['rabbitmq']['ssl'].empty?
      end
    else
      conf['rabbitmq']['ssl'] ||= {}
    end
  end

  def ssl_private_key
    if conf['rabbitmq'].class != Array
      if conf['rabbitmq'].has_key? 'ssl'
        conf['rabbitmq']['ssl']['private_key_file'] || ''
      else
        ''
      end
    else
      ''
    end
  end

  def ssl_private_key=(value)
    if value == ''
      if conf['rabbitmq'].has_key? 'ssl'
        if conf['rabbitmq']['ssl'].has_key? 'private_key_file'
          conf['rabbitmq']['ssl'].delete 'private_key_file'
        end
        conf['rabbitmq'].delete 'ssl' if conf['rabbitmq']['ssl'].empty?
      end
    else
      (conf['rabbitmq']['ssl'] ||= {})['private_key_file'] = value
    end
  end

  def ssl_cert_chain
    if conf['rabbitmq'].class != Array
      if conf['rabbitmq'].has_key? 'ssl'
        conf['rabbitmq']['ssl']['cert_chain_file'] || ''
      else
        ''
      end
    else
      ''
    end
  end

  def ssl_cert_chain=(value)
    if value == ''
      if conf['rabbitmq'].has_key? 'ssl'
        if conf['rabbitmq']['ssl'].has_key? 'cert_chain_file'
          conf['rabbitmq']['ssl'].delete 'cert_chain_file'
        end
        conf['rabbitmq'].delete 'ssl' if conf['rabbitmq']['ssl'].empty?
      end
    else
      (conf['rabbitmq']['ssl'] ||= {})['cert_chain_file'] = value
    end
  end

  def config_file
    File.join(resource[:base_path],'rabbitmq.json').gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
  end

  def port
    pre_create if conf['rabbitmq'].class == Array
    conf['rabbitmq']['port'] ? conf['rabbitmq']['port'].to_s : :absent
  end

  def port=(value)
    conf['rabbitmq']['port'] = value.to_i unless value == :absent
  end

  def host
    conf['rabbitmq']['host'] || :absent
  end

  def host=(value)
    conf['rabbitmq']['host'] = value unless value == :absent
  end

  def user
    conf['rabbitmq']['user'] || :absent
  end

  def user=(value)
    conf['rabbitmq']['user'] = value unless value == :absent
  end

  def password
    conf['rabbitmq']['password'] || :absent
  end

  def password=(value)
    conf['rabbitmq']['password'] = value unless value == :absent
  end

  def vhost
    conf['rabbitmq']['vhost'] || :absent
  end

  def vhost=(value)
    conf['rabbitmq']['vhost'] = value unless value == :absent
  end

  def heartbeat
    conf['rabbitmq']['heartbeat'] ? conf['rabbitmq']['heartbeat'].to_s : :absent
  end

  def heartbeat=(value)
    conf['rabbitmq']['heartbeat'] = value.to_i unless value == :absent
  end

  def prefetch
    conf['rabbitmq']['prefetch'] ? conf['rabbitmq']['prefetch'].to_s : :absent
  end

  def prefetch=(value)
    conf['rabbitmq']['prefetch'] = value.to_i unless value == :absent
  end

  def cluster
    conf['rabbitmq']
  end

  def cluster=(value)
    conf['rabbitmq'] = value
  end
end
