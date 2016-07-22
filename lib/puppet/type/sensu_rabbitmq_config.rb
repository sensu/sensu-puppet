require 'set'
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                   'puppet_x', 'sensu', 'boolean_property.rb'))

Puppet::Type.newtype(:sensu_rabbitmq_config) do
  @doc = ""

  def initialize(*args)
    super *args

    self[:notify] = [
      "Service[sensu-server]",
      "Service[sensu-client]",
      "Service[sensu-api]",
    ].select { |ref| catalog.resource(ref) }
  end

  def has_cluster?
    cluster = self.should(:cluster)
    return cluster && !cluster.empty?
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

  newproperty(:ssl_transport, :parent => PuppetX::Sensu::BooleanProperty) do
    desc "Enable SSL transport to connect to RabbitMQ"

    defaultto :false
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

    defaultto {
      if !@resource.has_cluster? then '5672' end
    }
    def insync?(is)
      if should.is_a?(Symbol) then should == is else super(is) end
    end
  end

  newproperty(:host) do
    desc "The hostname that RabbitMQ is listening on"

    defaultto {
      if !@resource.has_cluster? then '127.0.0.1' end
    }
    def insync?(is)
      if should.is_a?(Symbol) then should == is else super(is) end
    end
  end

  newproperty(:user) do
    desc "The username to use when connecting to RabbitMQ"

    defaultto {
      if !@resource.has_cluster? then 'sensu' end
    }
    def insync?(is)
      if should.is_a?(Symbol) then should == is else super(is) end
    end
  end

  newproperty(:password) do
    desc "The password to use when connecting to RabbitMQ"
  end

  newproperty(:vhost) do
    desc "The vhost to use when connecting to RabbitMQ"

    defaultto {
      if !@resource.has_cluster? then 'sensu' end
    }
    def insync?(is)
      if should.is_a?(Symbol) then should == is else super(is) end
    end
  end

  newproperty(:reconnect_on_error) do
    desc "Attempt to reconnect to RabbitMQ on error"

    defaultto {
      if !@resource.has_cluster? then :false end
    }
    def insync?(is)
      if should.is_a?(Symbol) then should == is else super(is) end
    end
  end

  newproperty(:prefetch) do
    desc "The RabbitMQ AMQP consumer prefetch value"

    defaultto {
      if !@resource.has_cluster? then '1' end
    }
    def insync?(is)
      if should.is_a?(Symbol) then should == is else super(is) end
    end
  end

  newproperty(:cluster, :array_matching => :all) do
    desc "Rabbitmq Cluster"
    def insync?(is)
      Set.new(is) == Set.new(should)
    end

    munge do |value|
      Hash[value.map do |k, v|
        [k,if k == "port" then v.to_i elsif k == "prefetch" then v.to_i else v.to_s end]
      end]
    end
  end

  autorequire(:package) do
    ['sensu']
  end
end
