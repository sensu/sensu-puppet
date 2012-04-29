Puppet::Type.newtype(:sensu_redis_config) do
  @doc = ""

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

  newproperty(:port) do
    desc "The port that Redis is listening on"

    defaultto '6379'
  end

  newproperty(:host) do
    desc "The hostname that Redis is listening on"

    defaultto 'localhost'
  end
end
