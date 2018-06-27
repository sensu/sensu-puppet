require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_silenced) do
  desc <<-DESC
Manages Sensu silencing
@example Create a silencing
  sensu_silenced { 'test':
    ensure       => 'present',
    subscription => 'entity:sensu_agent',
  }
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc "Silenced name"
  end

  newproperty(:id) do
    desc "The unique ID of the silenced"
    validate do |value|
      fail "class is read-only"
    end
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

  newproperty(:organization) do
    desc "The Sensu RBAC organization that this silenced belongs to."
    defaultto 'default'
  end

  newproperty(:environment) do
    desc "The Sensu RBAC environment that this silenced belongs to."
    defaultto 'default'
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

