require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_hook) do
  desc <<-DESC
@summary Manages Sensu hooks
@example Create a hook
  sensu_hook { 'test':
    ensure  => 'present',
    command => 'ps aux',
  }

**Autorequires**:
* `Package[sensu-cli]`
* `Service[sensu-backend]`
* `Exec[sensuctl_configure]`
* `Sensu_api_validator[sensu]`
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

  newproperty(:namespace) do
    desc "The Sensu RBAC namespace that this hook belongs to."
    defaultto 'default'
  end

  newproperty(:labels, :parent => PuppetX::Sensu::HashProperty) do
    desc "Custom attributes to include with event data, which can be queried like regular attributes."
  end

  newproperty(:annotations, :parent => PuppetX::Sensu::HashProperty) do
    desc "Arbitrary, non-identifying metadata to include with event data."
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
