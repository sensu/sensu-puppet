Puppet::Type.newtype(:sensu_client_subscription) do
  @doc = ""

  def initialize(*args)
    super

    self[:notify] = [
      "Service[sensu-client]",
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
    desc "The subscription name"
  end

  newparam(:base_path) do
    desc "The base path to the client config file"
    defaultto '/etc/sensu/conf.d/'
  end

  newparam(:subscriptions) do
    desc "Subscriptions included"
    defaultto :name
    munge do |value|
      Array(value)
    end
  end

  autorequire(:package) do
    ['sensu']
  end
end
