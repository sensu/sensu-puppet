require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/hash_of_strings_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_entity) do
  desc <<-DESC
@summary Manages Sensu entities
@example Create an entity
  sensu_entity { 'test':
    ensure       => 'present',
    entity_class => 'proxy',
  }

@example Create an entity with namespace `dev` in the name
  sensu_entity { 'test in dev':
    ensure       => 'present',
    entity_class => 'proxy',
  }

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensuctl_configure[puppet]`
* `Sensu_api_validator[sensu]`
* `Sensu_user[admin]`
* `sensu_namespace` - Puppet will autorequire `sensu_namespace` resource defined in `namespace` property.
* `sensu_handler` - Puppet will autorequie `sensu_handler` resource defined in `deregistration.handler` property.
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc <<-EOS
    The name of the entity.
    The name supports composite names that can define the namespace.
    An example composite name to define resource named `test` in namespace `dev`: `test in dev`
    EOS
  end

  newparam(:resource_name, :namevar => true) do
    desc "The name of the entity."
    validate do |value|
      unless value =~ PuppetX::Sensu::Type.name_regex
        raise ArgumentError, "sensu_entity name invalid"
      end
    end
    defaultto do
      @resource[:name]
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

  newproperty(:deregistration, :parent => PuppetX::Sensu::HashProperty) do
    desc <<-EOS
    A map containing a handler name, for use when an entity is deregistered.

    Valid keys:
    * handler - Opional - The name of the handler to be called when an entity is deregistered.
    EOS
    validate do |value|
      super(value)
      valid_keys = ['handler']
      value.keys.each do |key|
        if ! valid_keys.include?(key)
          raise ArgumentError, "#{key} is not a valid key for deregistration"
        end
      end
      if value.key?('handler') && ! value['handler'].is_a?(String)
        raise ArgumentError, "deregistration.handler must be a String"
      end
    end
  end

  newproperty(:redact, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "List of items to redact from log messages."
  end

  newproperty(:namespace, :namevar => true) do
    desc "The Sensu RBAC namespace that this entity belongs to."
    defaultto 'default'
  end

  newproperty(:labels, :parent => PuppetX::Sensu::HashOfStringsProperty) do
    desc "Custom attributes to include with event data, which can be queried like regular attributes."
  end

  newproperty(:annotations, :parent => PuppetX::Sensu::HashOfStringsProperty) do
    desc "Arbitrary, non-identifying metadata to include with event data."
  end

  autorequire(:sensu_handler) do
    handler = []
    if self[:deregistration]
      if self[:deregistration].key?('handler')
        handler = [self[:deregistration]['handler']]
      end
    end
    handler
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
      :entity_class,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
    PuppetX::Sensu::Type.validate_namespace(self)
  end
end

