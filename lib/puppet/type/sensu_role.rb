require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_role) do
  desc <<-DESC
Manages Sensu roles
@example Add a role
  sensu_role { 'test':
    ensure => 'present',
    rules  => [{'type' => '*', 'environment' => '*', 'organization' => '*', 'permissions' => ['read']}],
  }
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the role."
    validate do |value|
      unless value =~ /^[\w\.\-]+$/
        raise ArgumentError, "sensu_role name invalid"
      end
    end
  end

  newproperty(:rules, :array_matching => :all) do
    desc "The rulesets that a role applies."
    validate do |rule|
      if ! rule.is_a?(Hash)
        raise ArgumentError, "Each rule must be a Hash not #{rule.class}"
      end
      valid_keys = ['type','environment','organization','permissions']
      valid_keys.each do |t|
        if ! rule.key?(t)
          raise ArgumentError, "A rule must contain #{t}"
        end
      end
      rule.keys.each do |t|
        if ! valid_keys.include?(t)
          raise ArgumentError, "Rule key #{t} is not valid"
        end
      end
      if ! rule['permissions'].is_a?(Array)
        raise ArgumentError, "A rule's permissions must be an array"
      end 
    end
  end

  validate do
    required_properties = [
      :rules
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
  end
end
