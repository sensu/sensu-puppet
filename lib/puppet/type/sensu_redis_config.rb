require 'puppet/property/boolean'

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

    defaultto 'localhost'
  end

  newproperty(:password) do
    desc "The password used to connect to Redis"
  end

  newproperty(:reconnect_on_error, :parent => Puppet::Property::Boolean) do
    desc "Attempt to reconnect to RabbitMQ on error"

    defaultto :false # not boolean since puppet ignores non-truthy defaults
                     # will still be munged to boolean
  end

  autorequire(:package) do
    ['sensu']
  end
end
