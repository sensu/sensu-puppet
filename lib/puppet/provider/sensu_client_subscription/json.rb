require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?

Puppet::Type.type(:sensu_client_subscription).provide(:json) do
  confine :feature => :json

  def initialize(*args)
    super

    begin
      @conf = JSON.parse(File.read(config_file))
    rescue
      @conf = {}
    end
  end

  def flush
    File.open(config_file, 'w') do |f|
      f.puts JSON.pretty_generate(@conf)
    end
  end

  def config_file
    "#{resource[:base_path]}/subscription_#{resource[:name]}.json"
  end

  def create
    @conf['client'] = {'subscriptions' => [ resource[:name] ] }
  end

  def destroy
    @conf = nil
  end

  def subscriptions
    @conf['client']['subscriptions']
  end

  def subscriptions=(value)
    @conf['client']['subscriptions'] = value
  end

  def exists?
    @conf.has_key?('client') && @conf['client'].has_key?('subscriptions')
  end
end

