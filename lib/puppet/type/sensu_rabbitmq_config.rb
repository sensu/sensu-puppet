Puppet::Type.newtype(:sensu_rabbitmq_config) do
  @doc = ""

  def initialize(*args)
    super

    self[:notify] = [
      "Service[sensu-server]",
      "Service[sensu-client]",
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

  newparam(:base_path) do
    desc "The base path to the client config file"
    defaultto '/etc/sensu/conf.d/'
  end

  newproperty(:ssl_private_key) do
    desc "The path on disk to the SSL private key needed to connect to RabbitMQ"

    defaultto ''
  end

  newproperty(:ssl_cert_chain) do
    desc "The path on disk to the SSL cert chain needed to connect to RabbitMQ"

    defaultto ''
  end

  newproperty(:port) do
    desc "The port that RabbitMQ is listening on"

    defaultto '5672'
  end

  newproperty(:host) do
    desc "The hostname that RabbitMQ is listening on"

    defaultto 'localhost'
  end

  newproperty(:user) do
    desc "The username to use when connecting to RabbitMQ"

    defaultto 'sensu'
  end

  newproperty(:password) do
    desc "The password to use when connecting to RabbitMQ"
  end

  newproperty(:vhost) do
    desc "The vhost to use when connecting to RabbitMQ"

    defaultto '/sensu'
  end

  autorequire(:package) do
    ['sensu']
  end
end
