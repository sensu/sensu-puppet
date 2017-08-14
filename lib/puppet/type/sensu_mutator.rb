Puppet::Type.newtype(:sensu_mutator) do
  @doc = "Manages Sensu mutators"

  def initialize(*args)
    super *args

    if c = catalog
      self[:notify] = [
        'Service[sensu-server]',
        'Service[sensu-enterprise]',
      ].select { |ref| c.resource(ref) }
    end
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
    desc "The name of the mutator"
  end

  newproperty(:command) do
    desc "Command the mutator should run"
  end

  newproperty(:timeout) do
    desc "The mutator execution duration timeout in seconds (hard stop)."
  end

  newparam(:base_path) do
    desc "The base path to the client config file"
    defaultto '/etc/sensu/conf.d/mutators/'
  end

  autorequire(:package) do
    ['sensu']
  end
end
