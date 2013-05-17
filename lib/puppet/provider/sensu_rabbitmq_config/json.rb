require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_rabbitmq_config).provide(:json) do
  confine :feature => :json

  def conf
    begin
      @conf ||= JSON.parse(File.read('/etc/sensu/conf.d/rabbitmq.json'))
    rescue
      @conf ||= {}
    end
  end

  def flush
    File.open('/etc/sensu/conf.d/rabbitmq.json', 'w') do |f|
      f.puts JSON.pretty_generate(conf)
    end
  end

  def create
    conf['rabbitmq'] = {}
    self.ssl_private_key = resource[:ssl_private_key] unless resource[:ssl_private_key].nil?
    self.ssl_cert_chain = resource[:ssl_cert_chain] unless resource[:ssl_cert_chain].nil?
    self.port = resource[:port]
    self.host = resource[:host]
    self.user = resource[:user]
    self.password = resource[:password]
    self.vhost = resource[:vhost]
  end

  def destroy
    conf.delete 'rabbitmq'
  end

  def exists?
    conf.has_key? 'rabbitmq'
  end

  def ssl_private_key
    if conf['rabbitmq'].has_key? 'ssl'
      conf['rabbitmq']['ssl']['private_key_file'] || ''
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
    if conf['rabbitmq'].has_key? 'ssl'
      conf['rabbitmq']['ssl']['cert_chain_file'] || ''
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

  def port
    conf['rabbitmq']['port'].to_s
  end

  def port=(value)
    conf['rabbitmq']['port'] = value.to_i
  end

  def host
    conf['rabbitmq']['host']
  end

  def host=(value)
    conf['rabbitmq']['host'] = value
  end

  def user
    conf['rabbitmq']['user']
  end

  def user=(value)
    conf['rabbitmq']['user'] = value
  end

  def password
    conf['rabbitmq']['password']
  end

  def password=(value)
    conf['rabbitmq']['password'] = value
  end

  def vhost
    conf['rabbitmq']['vhost']
  end

  def vhost=(value)
    conf['rabbitmq']['vhost'] = value
  end
end
