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

  newproperty(:bind) do
    desc "The bind IP that sensu will bind to"

    defaultto '0.0.0.0'
  end

  newparam(:base_path) do
    desc "The base path to the client config file"
    defaultto '/etc/sensu/conf.d/'
  end

  newproperty(:user) do
    desc "The username used for clients to authenticate against the Sensu API"
  end

  newproperty(:password) do
    desc "The password use for client authentication against the Sensu API"
  end

  autorequire(:package) do
    ['sensu']
  end
end
