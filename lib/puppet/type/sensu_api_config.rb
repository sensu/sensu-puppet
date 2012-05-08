Puppet::Type.newtype(:sensu_api_config) do
  @doc = ""

  def initialize(*args)
    super

    self[:notify] = [
      "Service[sensu-api]",
      "Service[sensu-dashboard]",
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

  newproperty(:port) do
    desc "The port that the Sensu API is listening on"

    defaultto '4567'
  end

  newproperty(:host) do
    desc "The hostname that the Sensu API is listening on"

    defaultto 'localhost'
  end

  autorequire(:package) do
    ['sensu']
  end
end
