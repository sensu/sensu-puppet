require 'set'
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                   'puppet_x', 'sensu', 'boolean_property.rb'))

Puppet::Type.newtype(:sensu_redis_config) do
  @doc = "Manages Sensu Redis config"

  def initialize(*args)
    super *args

    if c = catalog
      self[:notify] = [
        'Service[sensu-api]',
        'Service[sensu-server]',
        'Service[sensu-enterprise]',
      ].select { |ref| c.resource(ref) }
    end
  end

  def has_sentinels?
    sentinels = self.should(:sentinels)
    return sentinels && !sentinels.empty?
  end

  def pre_run_check
    if self.has_sentinels? then
      if self.should(:host) && self.should(:host) != :absent then
        raise Puppet::Error, "Redis 'host' (#{self.should(:host)}) must not be specified when sentinels are specified"
      end
      if self.should(:port) && self.should(:port) != :absent then
        raise Puppet::Error, "Redis 'port' (#{self.should(:port)}) must not be specified when sentinels are specified"
      end
    end
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

  newproperty(:port) do
    desc "The port that Redis is listening on"

    defaultto {
      if !@resource.has_sentinels? then '6379' else :absent end
    }
    def insync?(is)
      if should.is_a?(Symbol) then should == is else super(is) end
    end
  end

  newproperty(:host) do
    desc "The hostname that Redis is listening on"

    defaultto {
      # Use absent to ensure that config is flushed
      # when property gets unset
      if !@resource.has_sentinels? then '127.0.0.1' else :absent end
    }
    def insync?(is)
      if should.is_a?(Symbol) then should == is else super(is) end
    end
  end

  newproperty(:password) do
    desc "The password used to connect to Redis"
  end

  newproperty(:reconnect_on_error, :parent => PuppetX::Sensu::BooleanProperty) do
    desc "Attempt to reconnect to RabbitMQ on error"
    defaultto :true
  end

  newproperty(:db) do
    desc "The Redis instance DB to use/select"

    defaultto '0'
  end

  newproperty(:auto_reconnect) do
    desc "Reconnect to Redis in the event of a connection failure"

    defaultto :true
  end

  newproperty(:sentinels, :array_matching => :all) do
    desc "Redis Sentinel configuration for HA clustering"
    defaultto []

    def insync?(is)
      # this probably needs more checks, for duplicate values, etc
      # but for now it works fine
      Set.new(is) == Set.new(should)
    end

    munge do |value|
      hsh_ary = value.map {|k,v| [k, k == "port" ? v.to_i : v.to_s] }
      Hash[hsh_ary]
    end
  end

  newproperty(:master) do
    desc "Redis master name in the sentinel configuration"
    # Use absent to ensure that config is flushed
    # when property gets unset
    defaultto :absent
    def insync?(is)
      if should.is_a?(Symbol) then should == is else super(is) end
    end
  end

  autorequire(:package) do
    ['sensu']
  end
end
