Puppet::Type.newtype(:sensu_check_config) do
  @doc = ""

  def initialize(*args)
    super
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
    desc "The key name of the check"
  end

  newproperty(:config) do
    desc "Configuration for the check"
  end

  newproperty(:additional) do
    desc "Additional cnfiguration to send with events to handlers"
  end

  autorequire(:package) do
    ['sensu']
  end
end
