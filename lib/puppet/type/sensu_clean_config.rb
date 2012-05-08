Puppet::Type.newtype(:sensu_clean_config) do
  @doc = ""

  ensurable do
    newvalue(:absent) do
      provider.destroy
    end

    defaultto :absent
  end

  newparam(:name) do
    desc "This value has no effect, set it to what ever you want."
  end

  autorequire(:package) do
    ['sensu']
  end
end
