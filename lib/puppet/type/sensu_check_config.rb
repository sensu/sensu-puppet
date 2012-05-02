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
    desc "Some unique name, not the name of the check."
  end

  newparam(:realname) do
    desc "The name of the check"
  end

  newproperty(:handlers, :array_matching => :all) do
    desc ""
  end

  newproperty(:command) do
    desc ""
  end

  newproperty(:interval) do
    desc ""
  end

  newproperty(:subscribers, :array_matching => :all) do
    desc ""
  end
end
