require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                   'puppet_x', 'sensu', 'boolean_property.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                   'puppet_x', 'sensu', 'to_type.rb'))

Puppet::Type.newtype(:sensu_client_config) do
  @doc = ""

  def initialize(*args)
    super *args

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
    desc "The name of the host"
  end

  newproperty(:client_name) do
    desc ""
  end

  newproperty(:address) do
    desc ""
  end

  newproperty(:subscriptions, :array_matching => :all) do
    desc ""
    def insync?(is)
      is.sort == should.sort
    end
  end

  newproperty(:redact, :array_matching => :all) do
    desc "An array of strings that should be redacted in the sensu client config"
    def insync?(is)
      is.sort == should.sort
    end
  end

  newproperty(:socket) do
    desc "A set of attributes that configure the Sensu client socket."
    include PuppetX::Sensu::ToType

    munge do |value|
      value.each { |k, v| value[k] = to_type(v) }
    end

    def insync?(is)
      if defined? @should[0]
        if is == @should[0].each { |k, v| value[k] = to_type(v) }
          true
        else
          false
        end
      else
        true
      end
    end

    defaultto {}
  end

  newparam(:base_path) do
    desc "The base path to the client config file"
    defaultto '/etc/sensu/conf.d/'
  end

  newproperty(:safe_mode, :parent => PuppetX::Sensu::BooleanProperty) do
    desc "Require checks to be defined on server and client"

    defaultto :false # property assumed as managed in provider (no nil? checks)
  end

  newproperty(:custom) do
    desc "Custom client variables"

    include PuppetX::Sensu::ToType

    munge do |value|
      value.each { |k, v| value[k] = to_type(v) }
    end

    def is_to_s(hash = @is)
      hash.keys.sort.map {|key| "#{key} => #{hash[key]}"}.join(", ")
    end

    def should_to_s(hash = @should)
      hash.keys.sort.map {|key| "#{key} => #{hash[key]}"}.join(", ")
    end

    def insync?(is)
      if defined? @should[0]
        if is == @should[0].each { |k, v| value[k] = to_type(v) }
          true
        else
          false
        end
      else
        true
      end
    end

    defaultto {}
  end

  newproperty(:keepalive) do
    desc "Keepalive config"

    include PuppetX::Sensu::ToType

    munge do |value|
      value.each { |k, v| value[k] = to_type(v) }
    end

    def is_to_s(hash = @is)
      hash.keys.sort.map {|key| "#{key} => #{hash[key]}"}.join(", ")
    end

    def should_to_s(hash = @should)
      hash.keys.sort.map {|key| "#{key} => #{hash[key]}"}.join(", ")
    end

    def insync?(is)
      if defined? @should[0]
        if is == @should[0].each { |k, v| value[k] = to_type(v) }
          true
        else
          false
        end
      else
        true
      end
    end

    defaultto {}
  end


  autorequire(:package) do
    ['sensu']
  end
end
