Puppet::Type.newtype(:sensu_check_config) do
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
