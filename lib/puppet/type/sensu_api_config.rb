require 'puppet/parameter/boolean'

Puppet::Type.newtype(:sensu_api_config) do
  @doc = ""

  def initialize(*args)
    super *args

    self[:notify] = [
      "Service[sensu-api]",
      "Service[sensu-enterprise]",
    ].select { |ref| catalog.resource(ref) if catalog }
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

    defaultto '4567'
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

  newparam(:ssl, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'Whether to configure the SSL listener.'

    defaultto false
  end

  newproperty(:ssl_port) do
    desc 'The API HTTPS (SSL) port.'

    defaultto { :absent }
  end

  newproperty(:ssl_keystore_file) do
    desc 'The file path for the SSL certificate keystore.'

    defaultto { :absent }
  end

  newproperty(:ssl_keystore_password) do
    desc 'The SSL certificate keystore password.'

    defaultto { :absent }
  end

  validate do
    unless self[:ssl]
      self.fail 'Do not define ssl_port unless ssl => true' if self[:ssl_port] != :absent
      self.fail 'Do not define ssl_keystore_file unless ssl => true' if self[:ssl_keystore_file] != :absent
      self.fail 'Do not define ssl_keystore_password unless ssl => true' if self[:ssl_keystore_password] != :absent
    end
  end

  autorequire(:package) do
    ['sensu']
  end
end
