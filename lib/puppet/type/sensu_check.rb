require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_check) do
  desc <<-DESC
Manages Sensu checks
@example Create a check
  sensu_check { 'test':
    ensure        => 'present',
    command       => 'check-http.rb',
    subscriptions => ['demo'],
    handlers      => ['email'],
    interval      => 60,
  }

@example Create a check that has a hook
  sensu_check { 'test':
    ensure        => 'present',
    command       => 'check-cpu.sh -w 75 -c 90',
    subscriptions => ['linux'],
    check_hooks   => [
      { 'critical' => ['ps'] },
      { 'warning'  => ['ps'] },
    ],
    interval      => 60,
  }

@example Create a check that is subdued
  sensu_check { 'test':
    ensure        => 'present',
    command       => 'test.sh',
    subscriptions => ['linux'],
    handlers      => ['email'],
    interval      => 60,
    subdue_days   => {
      'all' => [
        { 'begin' => '8:00 AM', 'end' => '5:00 PM' },
      ],
      'friday' => [
        { 'begin' => '7:00 AM', 'end' => '6:00 PM' },
      ],
    }
  }
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the check."
    validate do |value|
      unless value =~ /^[\w\.\-]+$/
        raise ArgumentError, "sensu_check name invalid"
      end
    end
  end

  newproperty(:command) do
    desc "Command to be run by the check"
  end

  newproperty(:subscriptions, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "An array of Sensu entity subscriptions that check requests will be sent to."
  end

  newproperty(:handlers, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "List of handlers that responds to this check"
  end

  newproperty(:interval, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "How frequently the check runs in seconds"
    newvalues(/^[0-9]+$/, :absent)
  end

  newproperty(:cron) do
    desc 'When the check should be executed, using the Cron syntax.'
    newvalues(/.*/, :absent)
  end

  newproperty(:publish, :boolean => true) do
    desc "If check requests are published for the check."
    newvalues(:true, :false)
  end

  newproperty(:timeout, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "The check execution duration timeout in seconds (hard stop)."
    newvalues(/^[0-9]+$/, :absent)
  end

  newproperty(:ttl, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "Check ttl in seconds"
    newvalues(/^[0-9]+$/, :absent)
  end

  newproperty(:stdin, :boolean => true) do
    desc "If the Sensu agent writes JSON serialized Sensu entity and check data to the command process’ STDIN"
    newvalues(:true, :false)
  end

  newproperty(:low_flap_threshold, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "The flap detection low threshold (% state change) for the check"
    newvalues(/^[0-9]+$/, :absent)
  end

  newproperty(:high_flap_threshold, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "The flap detection high threshold (% state change) for the check"
    newvalues(/^[0-9]+$/, :absent)
  end

  newproperty(:runtime_assets, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "An array of Sensu assets (names), required at runtime for the execution of the command"
    newvalues(/.*/, :absent)
  end

  newproperty(:check_hooks, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "An array of Sensu hooks, which are commands run by the Sensu agent in response to the result of the check command execution."
    validate do |value|
      if ! value.is_a?(Hash)
        raise ArgumentError, "check_hooks elements must be a Hash"
      end
      if value.keys.size > 1
        raise ArgumentError, "check_hooks Hash must only contain one key"
      end
      type = value.keys[0]
      hooks = value[type]
      type_valid = false
      if ['ok','warning','critical','unknown','non-zero'].include?(type)
        type_valid = true
      elsif type.to_s =~ /^\d+$/ && type.to_i.between?(1,255)
        type_valid = true
      end
      if ! type_valid
        raise ArgumentError, "check_hooks type value is invalid"
      end
      if ! hooks.is_a?(Array)
        raise ArgumentError, "check_hooks hooks must be an Array"
      end
    end
  end

  newproperty(:subdue_days, :parent => PuppetX::Sensu::HashProperty) do
    desc "A Sensu subdue, a hash of days of the week, which define one or more time windows in which the check is not scheduled to be executed."
    validate do |value|
      super(value)
      value.each_pair do |k,v|
        if ! ['monday','tuesday','wednesday','thursday','friday','saturday','sunday','all'].include?(k.to_s)
          raise ArgumentError, "subdue_days keys must be day of the week or 'all', not #{k}"
        end
        if ! v.is_a?(Array)
          raise ArgumentError, "subdue_days hash values must be an Array"
        end
        v.each do |d|
          if ! d.is_a?(Hash) || ! d.key?('begin') || ! d.key?('end')
            raise ArgumentError, "subdue_days day time window must be a hash containing keys 'begin' and 'end'"
          end
        end
      end
    end
  end

  newproperty(:proxy_entity_id) do
    desc "The check ID, used to create a proxy entity for an external resource (i.e., a network switch)."
    newvalues(/^[\w\.\-]+$/, :absent)
    validate do |value|
      unless value =~ /^[\w\.\-]+$/
        raise ArgumentError, "check_check proxy_entity_id invalid"
      end
    end
  end

  newproperty(:round_robin, :boolean => true) do
    desc "If the check should be executed on a single entity within a subscription in a round-robin fashion."
    newvalues(:true, :false)
  end

  newproperty(:organization) do
    desc "The Sensu RBAC organization that this check belongs to."
    defaultto 'default'
  end

  newproperty(:environment) do
    desc "The Sensu RBAC environment that this check belongs to."
    defaultto 'default'
  end

  newproperty(:proxy_requests_entity_attributes, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "Sensu entity attributes to match entities in the registry, using Sensu Query Expressions"
  end

  newproperty(:proxy_requests_splay, :boolean => true) do
    desc "If proxy check requests should be splayed"
    newvalues(:true, :false)
  end

  newproperty(:proxy_requests_splay_coverage, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "The splay coverage percentage use for proxy check request splay calculation."
  end

  newproperty(:metric_format) do
    #desc
    newvalues(/.*/, :absent)
  end

  newproperty(:metric_handlers, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    #desc
    newvalues(/.*/, :absent)
  end

  newproperty(:output_metric_format) do
    #desc
    newvalues(/.*/, :absent)
  end

  newproperty(:output_metric_handlers, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    #desc
    newvalues(/.*/, :absent)
  end

  newproperty(:env_vars, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "An array of environment variables to use with command execution."
    newvalues(/.*/, :absent)
  end

  newproperty(:extended_attributes, :parent => PuppetX::Sensu::HashProperty) do
    desc "Custom attributes to include as with the check, that appear as outer-level attributes."
    defaultto {}
  end

  validate do
    required_properties = [
      :command,
      :subscriptions,
      :handlers,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
  end
end
