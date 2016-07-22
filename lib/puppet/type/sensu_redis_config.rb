require 'set'
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                   'puppet_x', 'sensu', 'boolean_property.rb'))

Puppet::Type.newtype(:sensu_redis_config) do
  @doc = ""

  def initialize(*args)
    super *args

    self[:notify] = [
      "Service[sensu-api]",
      "Service[sensu-server]",
    ].select { |ref| catalog.resource(ref) }
  end

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto :present
  end

  newparam(:name) do
    desc "This value has no effect, set it to what ever you want."
  end

  newparam(:base_path) do
    desc "The base path to the client config file"
    defaultto '/etc/sensu/conf.d/'
  end

  newproperty(:port) do
    desc "The port that Redis is listening on"

    defaultto '6379'
  end

  newproperty(:host) do
    desc "The hostname that Redis is listening on"

    defaultto '127.0.0.1'
  end

  newproperty(:password) do
    desc "The password used to connect to Redis"
  end

  newproperty(:reconnect_on_error, :parent => PuppetX::Sensu::BooleanProperty) do
    desc "Attempt to reconnect to RabbitMQ on error"

    defaultto :false
  end

  newproperty(:db) do
    desc "The Redis instance DB to use/select"

    defaultto '0'
  end

  newproperty(:auto_reconnect) do
    desc "Reconnect to Redis in the event of a connection failure"

    defaultto :true
  end

  newproperty(:sentinels_enabled, :parent => PuppetX::Sensu::BooleanProperty) do
    desc "Will Sentinelconfig be used or standard config"

    defaultto :false
  end

  newproperty(:sentinels, :array_matching => :all) do
    desc "Redis Sentinel configuration for HA clustering"
    def insync?(is)
      # this probably needs more checks, for duplicate values, etc
      # but for now it works fine
      Set.new(is) == Set.new(should)
    end
  end

  autorequire(:package) do
    ['sensu']
  end
end
