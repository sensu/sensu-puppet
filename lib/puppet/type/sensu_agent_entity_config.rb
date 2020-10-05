require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/hash_of_strings_property'
require_relative '../../puppet_x/sensu/integer_property'
require_relative '../../puppet_x/sensu/secrets_property'
require_relative '../../puppet_x/sensu/agent_entity_config'

Puppet::Type.newtype(:sensu_agent_entity_config) do
  desc <<-DESC
@summary Manages a Sensu agent subscription
@example Add a subscription to an agent using composite names
  sensu_agent_entity_config { 'subscription value linux on sensu-agent.example.org in dev':
    ensure => 'present',
  }

@example Add an annotation to an agent using composite names
  sensu_agent_entity_config { 'annotations key contacts on sensu-agent.example.org in dev':
    ensure => 'present',
    value  => 'dev@example.com',
  }

@example Add a subscription to an agent
  sensu_agent_entity_config { 'subscription':
    ensure    => 'present',
    config    => 'subscription',
    value     => 'linux',
    entity    => 'sensu-agent.example.org',
    namespace => 'dev',
  }

@example Add an annotation to an agent
  sensu_agent_entity_config { 'annotation-contacts':
    ensure    => 'present',
    config    => 'annotation',
    key       => 'contacts',
    value     => 'dev@example.com',
    entity    => 'sensu-agent.example.org',
    namespace => 'dev',
  }
    

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Service[sensu-agent]`
* `Sensuctl_configure[puppet]`
* `Sensu_api_validator[sensu]`
* `Sensu_user[admin]`
* `sensu_namespace` - Puppet will autorequire `sensu_namespace` resource defined in `namespace` property.
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable do
    newvalue(:present) do
      @resource.provider.create
    end
    newvalue(:absent) do
      @resource.provider.destroy
    end
    defaultto(:present)
  end

  newparam(:name, :namevar => true) do
    desc <<-EOS
    The name of the agent subscription.
    The name supports composite names that can define the entity and namespace.
    An example composite name to define subscription named `test` on entity 'agent' in namespace `dev`: `test on agent in dev`
    EOS
  end

  newparam(:config, :namevar => true) do
    desc "The name of the config to set."
    defaultto do
      @resource[:name]
    end
    validate do |value|
      if ! PuppetX::Sensu::AgentEntityConfig.config_classes.keys.include?(value)
        raise ArgumentError, "#{value} is not a supported config value"
      end
    end
  end

  newparam(:entity, :namevar => true) do
    desc "The entity to manage subscription"
  end

  newparam(:namespace, :namevar => true) do
    desc "The Sensu RBAC namespace that this entity belongs to."
    defaultto 'default'
  end

  newparam(:key, :namevar => true) do
    desc "Key of config entry set, for labels and annotations"
  end

  newproperty(:value, :namevar => true) do
    desc "The value of the config for agent entity"

    def insync?(is)
      return true if is == 'REDACTED'
      super(is)
    end
  end

  # This is only needed in case REDACTED values are encountered to ensure an update is performed
  # When agent.yaml is changed
  def refresh
    if PuppetX::Sensu::AgentEntityConfig.config_classes[@parameters[:config].value].is_a?(Hash) && provider.value == 'REDACTED'
      provider.update
    else
      debug 'Skipping refresh; config is not one that can be redacted'
    end
  end

  def self.title_patterns
    [
      [
        /^((\S+) value (\S+) on (\S+) in (\S+))$/,
        [
          [:name],
          [:config],
          [:value],
          [:entity],
          [:namespace],
        ],
      ],
      [
        /^((\S+) key (\S+) on (\S+) in (\S+))$/,
        [
          [:name],
          [:config],
          [:key],
          [:entity],
          [:namespace],
        ],
      ],
      [
        /^((\S+) on (\S+) in (\S+))$/,
        [
          [:name],
          [:config],
          [:entity],
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

  autorequire(:service) do
    ['sensu-backend', 'sensu-agent']
  end

  autorequire(:sensu_agent_entity_validator) do
    validator = []
    catalog.resources.each do |resource|
      next unless resource.class.to_s == "Puppet::Type::Sensu_agent_entity_validator"
      if resource.name == self[:entity] && resource[:namespace] == self[:namespace]
        validator << resource.name
        break
      end
    end
    validator
  end

  def pre_run_check
    if self[:entity].nil?
      fail "You must provide a value for entity"
    end
    config = PuppetX::Sensu::AgentEntityConfig.config_classes[self[:config]]
    if config.is_a?(Hash) && self[:key].nil?
      fail "You must provide a value for key"
    end
    if !config.is_a?(Hash) && self[:value].nil?
      fail "You must provide a value for the value property"
    end
    PuppetX::Sensu::Type.validate_namespace(self)
  end
end
