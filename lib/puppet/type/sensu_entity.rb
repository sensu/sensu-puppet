require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_entity) do
  desc <<-DESC
@summary Manages Sensu entities
@example Create an entity
  sensu_entity { 'test':
    ensure       => 'present',
    entity_class => 'proxy',
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
    desc "The unique name of the entity"
    validate do |value|
      unless value =~ /^[\w\.\-]+$/
        raise ArgumentError, "sensu_entity name invalid"
      end
    end
  end

  newproperty(:entity_class) do
    desc "The entity type"
    validate do |value|
      unless value =~ /^[\w\.\-]+$/
        raise ArgumentError, "sensu_entity entity_class invalid"
      end
    end
  end

  newproperty(:subscriptions, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "A list of subscription names for the entity"
  end

  newproperty(:system) do
    desc "System information about the entity, such as operating system and platform."
    validate do |value|
      fail "system is read-only"
    end
  end

  newproperty(:last_seen) do
    desc "Timestamp the entity was last seen, in epoch time."
    validate do |value|
      fail "last_seen is read-only"
    end
  end

  newproperty(:deregister, :boolean => true) do
    desc "If the entity should be removed when it stops sending keepalive messages."
    newvalues(:true, :false)
    defaultto(:false)
  end

  newproperty(:deregistration_handler) do
    desc "The name of the handler to be called when an entity is deregistered."
  end

  newproperty(:redact, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "List of items to redact from log messages."
  end

  newproperty(:namespace) do
    desc "The Sensu RBAC namespace that this entity belongs to."
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
      :entity_class,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
  end
end

