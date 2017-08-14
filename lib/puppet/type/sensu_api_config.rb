Puppet::Type.newtype(:sensu_api_config) do
  @doc = "Manages Sensu API config"

  def initialize(*args)
    super *args

    self[:notify] = [
      "Service[sensu-api]",
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
    desc "The port that the Sensu API is listening on"

    defaultto 4567

    munge do |value|
      value.to_i
    end
  end

  newproperty(:host) do
    desc "The hostname that the Sensu API is listening on"

    defaultto '127.0.0.1'
  end

  newproperty(:bind) do
    desc "The bind IP that sensu will bind to"

    defaultto '0.0.0.0'
  end

  newparam(:base_path) do
    desc "The base path to the client config file"
    defaultto '/etc/sensu/conf.d/'
  end

  newproperty(:user) do
    desc "The username used for clients to authenticate against the Sensu API"
  end

  newproperty(:password) do
    desc "The password use for client authentication against the Sensu API"
  end

  newproperty(:ssl_port) do
    desc "Port of the HTTPS (SSL) sensu api service. Enterprise only feature."
    munge do |value|
      value.to_i
    end
  end

  newproperty(:ssl_keystore_file) do
    desc "The file path for the SSL certificate keystore. Enterprise only feature."
  end

  newproperty(:ssl_keystore_password) do
    desc "The SSL certificate keystore password. Enterprise only feature."
  end

  autorequire(:package) do
    ['sensu']
  end
end
