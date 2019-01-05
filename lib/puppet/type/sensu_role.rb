require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_role) do
  desc <<-DESC
@summary Manages Sensu roles
@example Add a role
  sensu_role { 'test':
    ensure => 'present',
    rules  => [{'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => ['']}],
  }

**Autorequires**:
* `Package[sensu-cli]`
* `Service[sensu-backend]`
* `Exec[sensuctl_configure]`
* `Sensu_api_validator[sensu]`
* `sensu_namespace` - Puppet will autorequire `sensu_namespace` resource defined in `namespace` property.
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the role."
  end

  newproperty(:namespace) do
    desc "Namespace the role is restricted to."
    defaultto 'default'
  end

  newproperty(:rules, :array_matching => :all, :parent => PuppetX::Sensu::ArrayOfHashesProperty) do
    desc "The rulesets that a role applies."
    validate do |rule|
      if ! rule.is_a?(Hash)
        raise ArgumentError, "Each rule must be a Hash not #{rule.class}"
      end
      required_keys = ['verbs','resources']
      valid_keys = ['verbs','resources','resource_names']
      required_keys.each do |t|
        if ! rule.key?(t)
          raise ArgumentError, "A rule must contain #{t}"
        end
      end
      rule.keys.each do |t|
        if ! valid_keys.include?(t)
          raise ArgumentError, "Rule key #{t} is not valid"
        end
      end
      rule.each_pair do |k,v|
        if ! v.is_a?(Array)
          raise ArgumentError, "Rule's #{k} must be an Array"
        end
      end
    end
    munge do |value|
      if ! value.key?('resource_names')
        value['resource_names'] = nil
      end
      value
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
