require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_event) do
  desc <<-DESC
@summary Manages Sensu events
@example Resolve an event
  sensu_event { 'test for sensu-agent':
    ensure => 'resolve'
  }

@example Delete an event
  sensu_event { 'test for sensu-agent':
    ensure => 'absent'
  }

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensu_configure[puppet]`
* `Sensu_api_validator[sensu]`
* `sensu_namespace` - Puppet will autorequire `sensu_namespace` resource defined in `namespace` property.
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable do
    desc "The basic property that the resource should be in."
    nodefault
    newvalue(:present)
    newvalue(:resolve) do
      @resource.provider.resolve
    end
    newvalue(:absent) do
      @resource.provider.destroy
    end
    aliasvalue(:delete, :absent)

    def retrieve
      @resource.provider.state || :absent 
    end

    def insync?(is)
      if is.is_a?(Array)
        is = is[0]
      end
      if @should.is_a?(Array)
        should = @should[0]
      else
        should = @should
      end
      if is.to_sym == :absent && should.to_sym == :resolve
        true
      else
        super
      end
    end
  end

  newparam(:name, :namevar => true) do
    desc "Event name. Can take form of '<check> for <entity>'."
  end

  newparam(:entity, :namevar => true) do
    desc "The name of the entity the event should match"
  end

  newparam(:check, :namevar => true) do
    desc "The name of the check the event should match"
  end

  newparam(:namespace) do
    desc "The Sensu RBAC namespace that this event belongs to."
    defaultto 'default'
  end

  def self.title_patterns
    [
      [
        /^((\S+) for (\S+))$/,
        [
          [:name],
          [:check],
          [:entity],
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
    if ! self[:entity] || ! self[:check]
      fail "Must provide check and entity"
    end
  end

  def pre_run_check
    PuppetX::Sensu::Type.validate_namespace(self)
  end
end

