require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_namespace) do
  desc <<-DESC
Manages Sensu namespaces
@example Add an namespace
  sensu_namespace { 'test':
    ensure => 'present',
  }
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the namespace."
    validate do |value|
      unless value =~ /^[\w\.\-]+$/
        raise ArgumentError, "sensu_namespace name invalid"
      end
    end
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
