require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_handler) do
  @doc = "Manages Sensu handlers"

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the handler."
    validate do |value|
      unless value =~ /^[\w\.\-]+$/
        raise ArgumentError, "sensu_handler name invalid"
      end
    end
  end

  newproperty(:type) do
    desc "The handler type."
    newvalues('pipe', 'tcp', 'udp', 'set')
  end

  newproperty(:filters, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "An array of Sensu event filters (names) to use when filtering events for the handler."
    newvalues(/.*/, :absent)
  end

  newproperty(:mutator) do
    desc "The Sensu event mutator (name) to use to mutate event data for the handler."
    newvalues(/.*/, :absent)
  end

  newproperty(:timeout, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "The handler execution duration timeout in seconds (hard stop)"
    newvalues(/^[0-9]+$/, :absent)
  end

  newproperty(:command) do
    desc "The handler command to be executed."
    newvalues(/.*/, :absent)
  end

  newproperty(:env_vars, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "An array of environment variables to use with command execution."
    newvalues(/.*/, :absent)
  end

  newproperty(:handlers, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "An array of Sensu event handlers (names) to use for events using the handler set."
    newvalues(/.*/, :absent)
  end

  newproperty(:organization) do
    desc "The Sensu RBAC organization that this handler belongs to."
    defaultto 'default'
  end

  newproperty(:environment) do
    desc "The Sensu RBAC environment that this handler belongs to."
    defaultto 'default'
  end

  newproperty(:socket_host) do
    desc "The socket host address (IP or hostname) to connect to."
  end

  newproperty(:socket_port, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "The socket port to connect to."
  end

  newproperty(:custom, :parent => PuppetX::Sensu::HashProperty) do
    desc "Custom handler variables"
    defaultto {}
  end

  autorequire(:package) do
    ['sensu-cli']
  end

  autorequire(:service) do
    ['sensu-backend']
  end

  autorequire(:exec) do
    ['sensuctl_configure']
  end

  autorequire(:sensu_api_validator) do
    requires = []
    catalog.resources.each do |resource|
      if resource.class.to_s == 'Puppet::Type::Sensu_api_validator'
        requires << resource.name
      end
    end
    requires
  end

  validate do
    required_properties = [
      :type,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
    if !self[:command] && self[:type] == :pipe
      fail "command must be defined for type pipe"
    end
  end
end
