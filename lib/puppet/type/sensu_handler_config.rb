Puppet::Type.newtype(:sensu_handler_config) do
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
    desc "The key name of the handler"
  end

  newproperty(:config) do
    desc "Configuration for the handler"
  end

  autorequire(:package) do
    ['sensu']
  end
  
  autorequire(:file) do
    ['/etc/sensu/handlers']
  end
end
