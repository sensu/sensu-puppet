require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_config) do
  desc <<-DESC
@summary Manages Sensu configs
@example Manage a config
  sensu_config { 'format':
    value => 'json',
  }

**Autorequires**:
* `Package[sensu-cli]`
* `Service[sensu-backend]`
* `Exec[sensuctl_configure]`
* `Sensu_api_validator[sensu]`
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable do
    desc "The basic property that the resource should be in."
    defaultvalues
    validate do |value|
      if value.to_sym == :absent
        raise ArgumentError, "sensu_config ensure does not support absent"
      end
    end
  end

  newparam(:name, :namevar => true) do
    desc "The name of the config."
    validate do |value|
      unless value =~ /^[\w\.\-\_]+$/
        raise ArgumentError, "sensu_config name invalid"
      end
    end
  end

  newproperty(:value) do
    desc "The value of the config."
    munge do |value|
      value.to_s
    end
  end

  validate do
    required_properties = [
      :value,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
  end
end
