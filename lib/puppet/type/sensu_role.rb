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

@example Add a role with namespace `dev` in the name
  sensu_role { 'test in dev':
    ensure => 'present',
    rules  => [{'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => ['']}],
  }

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensuctl_configure[puppet]`
* `Sensu_api_validator[sensu]`
* `Sensu_user[admin]`
* `sensu_namespace` - Puppet will autorequire `sensu_namespace` resource defined in `namespace` property.
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc <<-EOS
    The name of the role.
    The name supports composite names that can define the namespace.
    An example composite name to define resource named `test` in namespace `dev`: `test in dev`
    EOS
  end

  newparam(:resource_name, :namevar => true) do
    desc "The name of the role."
    validate do |value|
      unless value =~ PuppetX::Sensu::Type.name_regex
        raise ArgumentError, "sensu_role name invalid"
      end
    end
    defaultto do
      @resource[:name]
    end
  end

  newproperty(:namespace, :namevar => true) do
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

  def self.title_patterns
    [
      [
        /^((\S+) in (\S+))$/,
        [
          [:name],
          [:resource_name],
          [:namespace],
        ],
      ],
      [
        /(.*)/,
        [
          [:name],
        ],
      ],
    ]
  end

  def pre_run_check
    required_properties = [
      :rules
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
    PuppetX::Sensu::Type.validate_namespace(self)
  end
end
