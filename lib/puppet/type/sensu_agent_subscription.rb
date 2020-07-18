require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/hash_of_strings_property'
require_relative '../../puppet_x/sensu/integer_property'
require_relative '../../puppet_x/sensu/secrets_property'

Puppet::Type.newtype(:sensu_agent_subscription) do
  desc <<-DESC
@summary Manages a Sensu agent subscription
@example Add a subscription to an agent using composite names
  sensu_agent_subscription { 'apache on sensu-agent.example.org in dev':
    ensure => 'present',
  }

@example Add a subscription to an agent
  sensu_agent_subscription { 'apache':
    ensure       => 'present',
    subscription => 'apache'
    entity       => 'sensu-agent.example.org',
    namespace    => 'dev',
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

  newparam(:subscription, :namevar => true) do
    desc "The name of the subscription."
    defaultto do
      @resource[:name]
    end
  end

  newparam(:entity, :namevar => true) do
    desc "The entity to manage subscription"
  end

  newparam(:namespace, :namevar => true) do
    desc "The Sensu RBAC namespace that this entity belongs to."
    defaultto 'default'
  end

  def self.title_patterns
    [
      [
        /^((\S+) on (\S+) in (\S+))$/,
        [
          [:name],
          [:subscription],
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

  def pre_run_check
    required_properties = [
      :entity,
    ]
    required_properties.each do |property|
      if self[property].nil?
        fail "You must provide a #{property}"
      end
    end
    PuppetX::Sensu::Type.validate_namespace(self)
  end
end
