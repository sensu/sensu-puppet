Puppet::Type.newtype(:sensu_dashboard_config) do
  @doc = ""

  def initialize(*args)
    super

    self[:notify] = [
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
    desc "The port that the Sensu Dashboard should listen on"

    defaultto '8080'
  end

  newproperty(:host) do
    desc "The hostname that the Sensu Dashboard should listen on"

    defaultto 'localhost'
  end

  newproperty(:bind) do
    desc "The IP dashboard will bind to"

    defaultto '0.0.0.0'
  end

  newproperty(:user) do
    desc "The username to use when connecting to the Sensu Dashboard"

    defaultto 'sensu'
  end

  newparam(:base_path) do
    desc "The base path to the client config file"
    defaultto '/etc/sensu/conf.d/'
  end

  newproperty(:password) do
    desc "The password to use when connecting to the Sensu Dashboard"
  end

  autorequire(:package) do
    ['sensu']
  end
end
