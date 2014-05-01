Puppet::Type.newtype(:sensu_check_config) do
  @doc = ""

  def initialize(*args)
    super

    self[:notify] = [
      "Service[sensu-client]",
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
    desc "The check name to configure"
  end

  newparam(:base_path) do
    desc "The base path to the client config file"
    defaultto '/etc/sensu/conf.d/checks'
  end

  newparam(:config) do
    desc "Check configuration for the client to use"
  end

  newparam(:event) do
    desc "Configuration to send with the event to handlers"
  end

  autorequire(:package) do
    ['sensu']
  end
end
