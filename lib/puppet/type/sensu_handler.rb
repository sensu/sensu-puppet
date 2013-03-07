Puppet::Type.newtype(:sensu_handler) do
  @doc = ""

  def initialize(*args)
    super

    self[:notify] = [
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
    desc "The name of the handler"
  end

  newproperty(:type) do
    desc "Type of handler"
  end

  newproperty(:command) do
    desc "Command the handler should run"
  end

  newproperty(:severities, :array_matching => :all) do
    desc "Severities applicable to this handler"
  end

  newproperty(:handlers) do
    desc "Handlers this handler mutexes into"
  end

  autorequire(:package) do
    ['sensu']
  end
end
