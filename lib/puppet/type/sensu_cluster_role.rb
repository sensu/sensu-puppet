require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_cluster_role) do
  desc <<-DESC
@summary Manages Sensu cluster roles
@example Add a cluster role
  sensu_cluster_role { 'test':
    ensure => 'present',
    rules  => [{'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => ['']}],
  }

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensuctl_configure[puppet]`
* `Sensu_api_validator[sensu]`
* `Sensu_user[admin]`
DESC

  extend PuppetX::Sensu::Type
  add_autorequires(false)

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the role."
    validate do |value|
      unless value =~ PuppetX::Sensu::Type.name_regex
        raise ArgumentError, "sensu_cluster_role name invalid"
      end
    end
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
        if ! v.nil? && ! v.is_a?(Array)
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
