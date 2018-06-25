require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_organization) do
  desc <<-DESC
Manages Sensu organizations
@example Add an organization
  sensu_organization { 'test':
    ensure      => 'present',
    description => 'Test organization',
  }
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the organization."
    validate do |value|
      unless value =~ /^[\w\.\-]+$/
        raise ArgumentError, "sensu_organization name invalid"
      end
    end
  end

  newproperty(:description) do
    desc "The organization description"
    newvalues(/.*/, :absent)
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
