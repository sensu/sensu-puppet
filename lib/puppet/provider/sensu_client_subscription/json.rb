require 'json' if Puppet.features.json?
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'provider_create.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                   'puppet_x', 'sensu', 'to_type.rb'))

Puppet::Type.type(:sensu_client_subscription).provide(:json) do
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
    "#{resource[:base_path]}/#{resource[:file_name]}"
  end

  def pre_create
    conf['client'] = {}
  end

  def destroy
    @conf = nil
  end

  def check_args
    ['name', 'address', 'subscriptions', 'safe_mode', 'bind']
  end

  def subscriptions
    conf['client']['subscriptions']
  end

  def subscriptions=(value)
    conf['client']['subscriptions'] = value
  end

  def custom
    conf['client'].reject { |k,v| check_args.include?(k) }
  end

  def custom=(value)
    conf['client'].delete_if { |k,v| not check_args.include?(k) }
    conf['client'].merge!(to_type(value))
  end

  def exists?
    conf.has_key?('client') && conf['client'].has_key?('subscriptions')
  end
end

