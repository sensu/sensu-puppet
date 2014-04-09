Puppet::Type.newtype(:sensu_redis_config) do
  @doc = ""

  def initialize(*args)
    super

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

  autorequire(:package) do
    ['sensu']
  end
end
