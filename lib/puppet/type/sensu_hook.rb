require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_hook) do
  desc <<-DESC
Manages Sensu hooks
@example Create a hook
  sensu_hook { 'test':
    ensure  => 'present',
    command => 'ps aux',
  }
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the hook."
    validate do |value|
      unless value =~ /^[\w\.\-]+$/
        raise ArgumentError, "sensu_hook name invalid"
      end
    end
  end

  newproperty(:command) do
    desc "The hook command to be executed."
  end

  newproperty(:timeout, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "The hook execution duration timeout in seconds (hard stop)"
    defaultto 60
  end

  newproperty(:stdin, :boolean => true) do
    desc "If the Sensu agent writes JSON serialized Sensu entity and check data to the command process’ STDIN."
    newvalues(:true, :false)
  end

  newproperty(:organization) do
    desc "The Sensu RBAC organization that this hook belongs to."
    defaultto 'default'
  end

  newproperty(:environment) do
    desc "The Sensu RBAC environment that this hook belongs to."
    defaultto 'default'
  end

  validate do
    required_properties = [
      :command,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
  end
end
