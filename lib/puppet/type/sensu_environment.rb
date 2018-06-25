require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_environment) do
  desc <<-DESC
Manages Sensu environments
@example Create an environment
  sensu_environment { 'test':
    ensure      => 'present',
    description => 'Test environment',
  }
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the environment."
    validate do |value|
      unless value =~ /^[\w\.\-]+$/
        raise ArgumentError, "sensu_environment name invalid"
      end
    end
  end

  newproperty(:description) do
    desc "The environment description"
    newvalues(/.*/, :absent)
  end

  newproperty(:organization) do
    desc "The Sensu RBAC organization that this environment belongs to."
    defaultto 'default'
  end

  validate do
    required_properties = [
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
  end
end
