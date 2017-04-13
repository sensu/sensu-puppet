require 'json' if Puppet.features.json?
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'provider_create.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'to_type.rb'))

Puppet::Type.type(:sensu_client_config).provide(:json) do
  confine :feature => :json
  include PuppetX::Sensu::ToType
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

  def config_file
    File.join(resource[:base_path], 'client.json').gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
  end

  def pre_create
    conf['client'] = {}
  end

  def destroy
    @conf = nil
  end

  def exists?
    conf.has_key?('client')
  end

  def check_args
    ['name', 'address', 'subscriptions', 'safe_mode', 'socket', 'keepalive', 'redact']
  end

  def client_name
    conf['client']['name']
  end

  def client_name=(value)
    conf['client']['name'] = value
  end

  def address
    conf['client']['address']
  end

  def address=(value)
    conf['client']['address'] = value
  end

  def socket
    conf['client']['socket']
  end

  def socket=(value)
    conf['client']['socket'] = value
  end

  def subscriptions
    conf['client']['subscriptions'] || []
  end

  def subscriptions=(value)
    conf['client']['subscriptions'] = value
  end

  def redact
    conf['client']['redact'] || []
  end

  def redact=(value)
    conf['client']['redact'] = value
  end

  def custom
    conf['client'].reject { |k,v| check_args.include?(k) }
  end

  def custom=(value)
    conf['client'].delete_if { |k,v| not check_args.include?(k) }
    conf['client'].merge!(to_type(value))
  end

  def keepalive
    conf['client']['keepalive'] || {}
  end

  def keepalive=(value)
    conf['client']['keepalive'] = to_type(value)
  end

  def safe_mode
    conf['client']['safe_mode']
  end

  def safe_mode=(value)
    conf['client']['safe_mode'] = value
  end

end
