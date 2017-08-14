require 'set'
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                   'puppet_x', 'sensu', 'boolean_property.rb'))

Puppet::Type.newtype(:sensu_rabbitmq_config) do
  @doc = 'Manages Sensu RabbitMQ config'

  def initialize(*args)
    super(*args)

    if c = catalog
      self[:notify] = [
        'Service[sensu-server]',
        'Service[sensu-client]',
        'Service[sensu-api]',
        'Service[sensu-enterprise]',
      ].select { |ref| c.resource(ref) }
    end
  end

  def has_cluster?
    cluster = should(:cluster)
    cluster && !cluster.empty?
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
    desc 'This value has no effect, set it to what ever you want.'
  end

  newparam(:base_path) do
    desc 'The base path to the client config file'
    defaultto '/etc/sensu/conf.d/'
  end

  newproperty(:ssl_transport, :parent => PuppetX::Sensu::BooleanProperty) do
    desc 'Enable SSL transport to connect to RabbitMQ'
    defaultto :false
  end

  newproperty(:ssl_private_key) do
    desc 'The path on disk to the SSL private key needed to connect to RabbitMQ'
    defaultto ''
  end

  newproperty(:ssl_cert_chain) do
    desc 'The path on disk to the SSL cert chain needed to connect to RabbitMQ'
    defaultto ''
  end

  newproperty(:port) do
    desc 'The port that RabbitMQ is listening on'
    defaultto { '5672' unless @resource.has_cluster? }

    def insync?(is)
      return should == is if should.is_a?(Symbol)
      super(is)
    end
  end

  newproperty(:host) do
    desc 'The hostname that RabbitMQ is listening on'
    defaultto { '127.0.0.1' unless @resource.has_cluster? }

    def insync?(is)
      return should == is if should.is_a?(Symbol)
      super(is)
    end
  end

  newproperty(:user) do
    desc 'The username to use when connecting to RabbitMQ'
    defaultto { 'sensu' unless @resource.has_cluster? }

    def insync?(is)
      return should == is if should.is_a?(Symbol)
      super(is)
    end
  end

  newproperty(:password) do
    desc 'The password to use when connecting to RabbitMQ'
  end

  newproperty(:vhost) do
    desc 'The vhost to use when connecting to RabbitMQ'
    defaultto { '/sensu' unless @resource.has_cluster? }

    def insync?(is)
      return should == is if should.is_a?(Symbol)
      super(is)
    end
  end

  newproperty(:heartbeat) do
    desc "The RabbitMQ heartbeat value"
    defaultto {30 unless @resource.has_cluster? }

    def insync?(is)
      return should == is if should.is_a?(Symbol)
      super(is)
    end
  end

  newproperty(:prefetch) do
    desc 'The RabbitMQ AMQP consumer prefetch value'
    defaultto { 1 unless @resource.has_cluster? }

    def insync?(is)
      return should == is if should.is_a?(Symbol)
      super(is)
    end
  end

  newproperty(:cluster, :array_matching => :all) do
    desc 'Rabbitmq Cluster'

    validate do |value|
      unless value.is_a?(Hash)
        raise ArgumentError, 'rabbitmq_cluster must be an array of more than 1 hash'
      end
    end

    munge do |value|
      value.reduce({}) do |acc, (k, v)|
        acc[k] =
          case k
          when 'port', 'prefetch', 'heartbeat' then v.to_i unless v.is_a?(Symbol)
          else v end
        acc
      end
    end

    def insync?(is)
      Set.new(is) == Set.new(should)
    end
  end

  autorequire(:package) do
    ['sensu']
  end
end
