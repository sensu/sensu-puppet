require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_silenced) do
  desc <<-DESC
@summary Manages Sensu silencing

The name of `sensu_silenced` can be used to define `check` and `subscription`.

@example Create a silencing for all checks with subscription entity:sensu_agent
  sensu_silenced { 'test':
    ensure       => 'present',
    subscription => 'entity:sensu_agent',
  }

@example Define silencing using composite name where `subscription=entity:sensu_agent` and `check=*`.
  sensu_silenced { 'entity:sensu_agent:*':
    ensure => 'present',
  }

@example Define silencing using composite name where `subscription=linux` and `check=check-http`.
  sensu_silenced { 'linux:check-http':
    ensure => 'present',
  }

**Autorequires**:
* `Package[sensu-cli]`
* `Service[sensu-backend]`
* `Sensu_configure[puppet]`
* `Sensu_api_validator[sensu]`
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc "Silenced name"
  end

  newparam(:check, :namevar => true) do
    desc "The name of the check the entry should match"
  end

  newparam(:subscription, :namevar => true) do
    desc "The name of the subscription the entry should match"
  end

  newproperty(:begin, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "Time at which silence entry goes into effect, in epoch."
  end

  newproperty(:expire, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "Number of seconds until this entry should be deleted."
    defaultto -1
  end

  newproperty(:expire_on_resolve, :boolean => true) do
    desc "If the entry should be deleted when a check begins return OK status (resolves)."
    newvalues(:true, :false)
    defaultto :false
  end

  newproperty(:creator) do
    desc "Person/application/entity responsible for creating the entry."
    newvalues(/.*/, :absent)
  end

  newproperty(:reason) do
    desc "Explanation for the creation of this entry."
    newvalues(/.*/, :absent)
  end

  newproperty(:namespace) do
    desc "The Sensu RBAC namespace that this silenced belongs to."
    defaultto 'default'
  end

  newproperty(:labels, :parent => PuppetX::Sensu::HashProperty) do
    desc "Custom attributes to include with event data, which can be queried like regular attributes."
  end

  newproperty(:annotations, :parent => PuppetX::Sensu::HashProperty) do
    desc "Arbitrary, non-identifying metadata to include with event data."
  end

  def self.title_patterns
    [
      [
        /^((entity:\S+):(\S+))$/,
        [
          [:name],
          [:subscription],
          [:check],
        ],
      ],
      [
        /^((\S+):(\S+))$/,
        [
          [:name],
          [:subscription],
          [:check],
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

  validate do
    if ! self[:check] && ! self[:subscription]
      fail "Must provide either check or subscription"
    end
  end

end

