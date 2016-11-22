require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
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
    if conf['rabbitmq'].class == Array then pre_create end
    if conf['rabbitmq']['port'] then conf['rabbitmq']['port'].to_s else :absent end
  end

  def port=(value)
    if value != :absent then conf['rabbitmq']['port'] = value.to_i end
  end

  def host
    conf['rabbitmq']['host'] || :absent
  end

  def host=(value)
    if value != :absent then conf['rabbitmq']['host'] = value end
  end

  def user
    conf['rabbitmq']['user'] || :absent
  end

  def user=(value)
    if value != :absent then conf['rabbitmq']['user'] = value end
  end

  def password
    conf['rabbitmq']['password'] || :absent
  end

  def password=(value)
    if value != :absent then conf['rabbitmq']['password'] = value end
  end

  def vhost
    conf['rabbitmq']['vhost'] || :absent
  end

  def vhost=(value)
    if value != :absent then conf['rabbitmq']['vhost'] = value end
  end

  def reconnect_on_error
    conf['rabbitmq']['reconnect_on_error'] || :absent
  end

  def reconnect_on_error=(value)
    if value != :absent then conf['rabbitmq']['reconnect_on_error'] = value end
  end

  def prefetch
    if conf['rabbitmq']['prefetch'] then conf['rabbitmq']['prefetch'].to_s else :absent end
  end

  def prefetch=(value)
    if value != :absent then conf['rabbitmq']['prefetch'] = value.to_i end
  end

  def cluster
    conf['rabbitmq']
  end

  def cluster=(value)
    conf['rabbitmq'] = value
  end
end
