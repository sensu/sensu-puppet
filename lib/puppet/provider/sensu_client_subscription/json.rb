require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?

begin
  require 'puppet_x/sensu/to_type'
rescue LoadError => e
  libdir = Pathname.new(__FILE__).parent.parent.parent.parent
  require File.join(libdir, 'puppet_x/sensu/to_type')
end

Puppet::Type.type(:sensu_client_subscription).provide(:json) do
  confine :feature => :json
  include Puppet_X::Sensu::Totype

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
    "#{resource[:base_path]}/subscription_#{resource[:name]}.json"
  end

  def create
    conf['client'] = {}
    self.subscriptions = [ resource[:name] ]
    self.custom = resource[:custom] unless resource[:custom].nil?
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

