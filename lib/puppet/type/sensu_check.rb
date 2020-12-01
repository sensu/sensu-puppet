require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/hash_of_strings_property'
require_relative '../../puppet_x/sensu/integer_property'
require_relative '../../puppet_x/sensu/secrets_property'

Puppet::Type.newtype(:sensu_check) do
  desc <<-DESC
@summary Manages Sensu checks
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

@example Create a check with namespace `dev` in the name
  sensu_check { 'test in dev':
    ensure        => 'present',
    command       => 'check-http.rb',
    subscriptions => ['demo'],
    handlers      => ['email'],
    interval      => 60,
  }

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensuctl_configure[puppet]`
* `Sensu_api_validator[sensu]`
* `Sensu_user[admin]`
* `sensu_namespace` - Puppet will autorequire `sensu_namespace` resource defined in `namespace` property.
* `sensu_handler` - Puppet will autorequie `sensu_handler` resources defined in `handlers` property.
* `sensu_asset` - Puppet will autorequire `sensu_asset` resources defined in `runtime_assets` property.
* `sensu_hook` - Puppet will autorequire `sensu_hook` resources defined in `check_hooks` property.
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc <<-EOS
    The name of the check.
    The name supports composite names that can define the namespace.
    An example composite name to define resource named `test` in namespace `dev`: `test in dev`
    EOS
  end

  newparam(:resource_name, :namevar => true) do
    desc "The name of the check."
    validate do |value|
      unless value =~ PuppetX::Sensu::Type.name_regex
        raise ArgumentError, "sensu_check name invalid - check name #{value}"
      end
    end
    defaultto do
      @resource[:name]
    end
  end

  newproperty(:command) do
    desc "The check command to be executed."
  end

  newproperty(:subscriptions, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "An array of Sensu entity subscriptions that check requests will be sent to."
  end

  newproperty(:handlers, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "An array of Sensu event handlers (names) to use for events created by the check."
  end

  newproperty(:interval, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "The frequency in seconds the check is executed."
    newvalues(/^[0-9]+$/, :absent)
  end

  newproperty(:cron) do
    desc 'When the check should be executed, using the Cron syntax.'
    newvalues(/.*/, :absent)
  end

  newproperty(:publish, :boolean => true) do
    desc "If check requests are published for the check."
    newvalues(:true, :false)
    defaultto(:true)
  end

  newproperty(:timeout, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "The check execution duration timeout in seconds (hard stop)."
    newvalues(/^[0-9]+$/, :absent)
  end

  newproperty(:ttl, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "The time to live (TTL) in seconds until check results are considered stale."
    newvalues(/^[0-9]+$/, :absent)
  end

  newproperty(:stdin, :boolean => true) do
    desc "If the Sensu agent writes JSON serialized Sensu entity and check data to the command process' STDIN"
    newvalues(:true, :false)
    defaultto(:false)
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

  newproperty(:check_hooks, :array_matching => :all, :parent => PuppetX::Sensu::ArrayOfHashesProperty) do
    desc "An array of check response types with respective arrays of Sensu hook names."
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
      elsif type.to_s =~ /^\d+$/ && type.to_i.between?(0,255)
        type_valid = true
      end
      if ! type_valid
        raise ArgumentError, "check_hooks type #{type} is invalid"
      end
      if ! hooks.is_a?(Array)
        raise ArgumentError, "check_hooks hooks must be an Array"
      end
    end
    munge do |value|
      type = value.keys[0]
      hooks = value[type]
      { type.to_s => hooks }
    end
  end

  newproperty(:proxy_entity_name) do
    desc "The entity name, used to create a proxy entity for an external resource (i.e., a network switch)."
    newvalues(/^[\w\.\-]+$/, :absent)
    validate do |value|
      unless value =~ /^[\w\.\-]+$/
        raise ArgumentError, "check_check proxy_entity_name invalid"
      end
    end
  end

  newproperty(:round_robin, :boolean => true) do
    desc "If the check should be executed on a single entity within a subscription in a round-robin fashion."
    newvalues(:true, :false)
  end

  newproperty(:proxy_requests, :parent => PuppetX::Sensu::HashProperty) do
    desc <<-EOS
    Proxy requests attributes

    Valid keys:
    * entity_attributes - Optional Array
    * splay - Optional Boolean (default: false)
    * splay_coverage - Optional Integer (default: 0)
    EOS
    validate do |value|
      super(value)
      valid_keys = ['entity_attributes','splay','splay_coverage']
      value.keys.each do |key|
        if ! valid_keys.include?(key)
          raise ArgumentError, "#{key} is not a valid key for proxy_requests"
        end
      end
      if value.key?('entity_attributes') && ! value['entity_attributes'].is_a?(Array)
        raise ArgumentError, "proxy_requests.entity_attributes must be an Array"
      end
      if value.key?('splay') && !!value['splay'] != value['splay']
        raise ArgumentError, "proxy_requests.splay must be a Boolean"
      end
      if value.key?('splay_coverage') && ! value['splay_coverage'].is_a?(Integer)
        raise ArgumentError, "proxy_requests.splay_coverage must be an Integer"
      end
    end
    munge do |v|
      if ! v.key?('splay')
        v['splay'] = false
      end
      if ! v.key?('splay_coverage')
        v['splay_coverage'] = 0
      end
      v
    end
  end

  newproperty(:silenced, :boolean => true) do
    desc "If the event is to be silenced."
    newvalues(:true, :false)
  end

  newproperty(:env_vars, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "An array of environment variables to use with command execution."
    newvalues(/.*/, :absent)
  end

  newproperty(:output_metric_format) do
    desc "The metric format generated by the check command."
    newvalues(:nagios_perfdata, :graphite_plaintext, :influxdb_line, :opentsdb_line, :prometheus_text, :absent)
  end

  newproperty(:output_metric_handlers, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "An array of Sensu handlers to use for events created by the check."
    newvalues(/.*/, :absent)
  end

  newproperty(:output_metric_tags, :array_matching => :all, :parent => PuppetX::Sensu::ArrayOfHashesProperty) do
    desc <<-EOS
    Custom tags you can apply to enrich metric points produced by check output metric extraction."
    Consists of Array of Hashes, each Hash must contain `name` and `value` keys.
    EOS

    validate do |tag|
      if ! tag.is_a?(Hash)
        raise ArgumentError, "Each tag must be a Hash not #{tag.class}"
      end
      required_keys = ['name','value']
      keys = tag.keys.map { |k| k.to_s }
      if required_keys.sort != keys.sort
        raise ArgumentError, "tag must contain only 'name' and 'value' keys"
      end
      tag.each_pair do |key, value|
        if ! value.is_a?(String)
          raise ArgumentError, "#{key} must be a String, not #{value.class}"
        end
      end
    end
  end

  newproperty(:max_output_size, :parent => PuppetX::Sensu::IntegerProperty) do
    desc 'Maximum size, in bytes, of stored check outputs.'
  end

  newproperty(:discard_output, :boolean => true) do
    desc 'Discard check output after extracting metrics.'
    newvalues(:true, :false)
  end

  newproperty(:secrets, :array_matching => :all, :parent => PuppetX::Sensu::SecretsProperty) do
    desc <<-EOS
    Array of the name/secret pairs to use with command execution.
    Example: [{'name' => 'ANSIBLE_HOST', 'secret' => 'sensu-ansible-host' }]
    EOS
  end

  newproperty(:namespace, :namevar => true) do
    desc "The Sensu RBAC namespace that this check belongs to."
    defaultto 'default'
  end

  newproperty(:labels, :parent => PuppetX::Sensu::HashOfStringsProperty) do
    desc "Custom attributes to include with event data, which can be queried like regular attributes."
  end

  newproperty(:annotations, :parent => PuppetX::Sensu::HashOfStringsProperty) do
    desc "Arbitrary, non-identifying metadata to include with event data."
  end

  autorequire(:sensu_handler) do
    self[:handlers]
  end

  autorequire(:sensu_asset) do
    self[:runtime_assets]
  end

  autorequire(:sensu_hook) do
    check_hooks = []
    (self[:check_hooks] || []).each do |check_hook|
      check_hook.each_pair do |severity, hooks|
        hooks.each do |hook|
          check_hooks << hook
        end
      end
    end
    check_hooks
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
      :command,
      :subscriptions,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
    if self[:ensure] == :present
      if (self[:interval].nil? && self[:cron].nil?) && self[:publish] == :true
        fail "interval or cron is required if publish is true"
      end
      if self[:interval].nil? && ! (self[:publish] == :false || ! self[:cron].nil?)
        fail "interval is required unless publish is false or cron is defined"
      end
      if self[:cron].nil? && ! (self[:publish] == :false || ! self[:interval].nil?)
        fail "cron is required unless publish is false or interval is defined"
      end
      if ( ! self[:interval].nil? && ! self[:ttl].nil? ) && ( self[:interval] != :absent && self[:ttl] != :absent )
        if self[:interval].to_i >= self[:ttl].to_i
          fail "check ttl #{self[:ttl]} must be greater than interval #{self[:interval]}"
        end
      end
    end
    PuppetX::Sensu::Type.validate_namespace(self)
  end
end
