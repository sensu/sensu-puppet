#require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
#                                   'puppet_x', 'sensu', 'to_type.rb'))

Puppet::Type.newtype(:sensu_check) do
  @doc = "Manages Sensu checks"

  class SensuCheckArrayProperty < Puppet::Property

    def should
      if @should and @should[0] == :absent
        :absent
      else
        @should
      end
    end

  end

  ensurable

  newparam(:name) do
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

  newproperty(:subscriptions, :array_matching => :all, :parent => SensuCheckArrayProperty) do
    desc "An array of Sensu entity subscriptions that check requests will be sent to."
    def insync?(is)
      return is.sort == should.sort if is.is_a?(Array) && should.is_a?(Array)
      is == should
    end
  end

  newproperty(:handlers, :array_matching => :all, :parent => SensuCheckArrayProperty) do
    desc "List of handlers that responds to this check"
    def insync?(is)
      return is.sort == should.sort if is.is_a?(Array) && should.is_a?(Array)
      is == should
    end
  end

  newproperty(:interval) do
    desc "How frequently the check runs in seconds"
    #newvalues(/^[0-9]+$/, :absent)
    validate do |value|
      unless value.to_s =~ /^\d+$/
        raise ArgumentError, "interval %s is not a valid integer" % value
      end
    end
    munge do |value|
      #value.to_s == 'absent' ? :absent : value.to_i
      value.to_i
    end
  end

  newproperty(:cron) do
    desc 'When the check should be executed, using the Cron syntax.'
    #newvalues(/.*/, :absent)
  end

  newproperty(:publish, :boolean => true) do
    desc "If check requests are published for the check."
    newvalues(:true, :false)
  end

  newproperty(:timeout) do
    desc "The check execution duration timeout in seconds (hard stop)."
    newvalues(/^[0-9]+$/, :absent)
    validate do |value|
      unless value.to_s =~ /^\d+$/
        raise ArgumentError, "timeout %s is not a valid integer" % value
      end
    end
    munge do |value|
      value.to_s == 'absent' ? :absent : value.to_i
    end
  end

  newproperty(:ttl) do
    desc "Check ttl in seconds"
    newvalues(/^[0-9]+$/, :absent)
    validate do |value|
      unless value.to_s =~ /^\d+$/
        raise ArgumentError, "ttl %s is not a valid integer" % value
      end
    end
    munge do |value|
      value.to_s == 'absent' ? :absent : value.to_i
    end
  end

  newproperty(:stdin, :boolean => true) do
    desc "If the Sensu agent writes JSON serialized Sensu entity and check data to the command process’ STDIN"
    newvalues(:true, :false)
  end

  newproperty(:low_flap_threshold) do
    desc "The flap detection low threshold (% state change) for the check"
    newvalues(/^[0-9]+$/, :absent)
    validate do |value|
      unless value.to_s =~ /^\d+$/
        raise ArgumentError, "low_flap_threshold %s is not a valid integer" % value
      end
    end
    munge do |value|
      value.to_s == 'absent' ? :absent : value.to_i
    end
  end

  newproperty(:high_flap_threshold) do
    desc "The flap detection high threshold (% state change) for the check"
    newvalues(/^[0-9]+$/, :absent)
    validate do |value|
      unless value.to_s =~ /^\d+$/
        raise ArgumentError, "high_flap_threshold %s is not a valid integer" % value
      end
    end
    munge do |value|
      value.to_s == 'absent' ? :absent : value.to_i
    end
  end

  newproperty(:runtime_assets, :array_matching => :all, :parent => SensuCheckArrayProperty) do
    desc "An array of Sensu assets (names), required at runtime for the execution of the command"
    newvalues(/.*/, :absent)
    def insync?(is)
      return is.sort == should.sort if is.is_a?(Array) && should.is_a?(Array)
      is == should
    end
  end

  newproperty(:check_hooks, :array_matching => :all, :parent => SensuCheckArrayProperty) do
    desc "An array of Sensu hooks (names), which are commands run by the Sensu agent in response to the result of the check command execution."
    newvalues(/.*/, :absent)
    def insync?(is)
      return is.sort == should.sort if is.is_a?(Array) && should.is_a?(Array)
      is == should
    end
  end

  newproperty(:subdue) do
    desc "A Sensu subdue, a hash of days of the week, which define one or more time windows in which the check is not scheduled to be executed."
    validate do |value|
      unless value.is_a?(Hash)
        raise ArgumentError, "sensu_check subdue must be a Hash"
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

  newproperty(:proxy_requests) do
    desc "A Sensu Proxy Requests, representing Sensu entity attributes to match entities in the registry."
    newvalues(:present, :absent)
  end
=begin
    validate do |value|
      unless value.is_a?(Hash)
        raise ArgumentError, "sensu_check proxy_requests must be a Hash"
      end
      valid_keys = ['entity_attributes', 'splay', 'splay_coverage']
      value.keys.each do |k|
        unless valid_keys.include?(k.to_s)
          raise ArgumentError, "proxy_requests invalid key #{k}"
        end
      end
    end
  end
=end

  newproperty(:round_robin, :boolean => true) do
    desc "If the check should be executed on a single entity within a subscription in a round-robin fashion."
    newvalues(:true, :false)
  end

  # extended_attributes

  newproperty(:organization) do
    desc "The Sensu RBAC organization that this check belongs to."
    #newvalues(/.*/, :absent)
  end

  newproperty(:environment) do
    desc "The Sensu RBAC environment that this check belongs to."
    #newvalues(/.*/, :absent)
  end

  newproperty(:proxy_requests_entity_attributes, :array_matching => :all, :parent => SensuCheckArrayProperty) do
    desc "Sensu entity attributes to match entities in the registry, using Sensu Query Expressions"
    #newvalues(/.*/, :absent)
    def insync?(is)
      return is.sort == should.sort if is.is_a?(Array) && should.is_a?(Array)
      is == should
    end
  end

  newproperty(:proxy_requests_splay, :boolean => true) do
    desc "If proxy check requests should be splayed"
    newvalues(:true, :false)
  end

  newproperty(:proxy_requests_splay_coverage) do
    desc "The splay coverage percentage use for proxy check request splay calculation."
    #newvalues(/^[0-9]+$/, :absent)
    validate do |value|
      unless value.to_s =~ /^\d+$/
        raise ArgumentError, "splay_coverage %s is not a valid integer" % value
      end
    end
    munge do |value|
      value.to_s == 'absent' ? :absent : value.to_i
    end
  end
=begin
  newproperty(:custom) do
    desc "Custom check variables"
    include PuppetX::Sensu::ToType

    def is_to_s(hash = @is)
      hash.keys.sort.map {|key| "#{key} => #{hash[key]}"}.join(", ")
    end

    def should_to_s(hash = @should)
      hash.keys.sort.map {|key| "#{key} => #{hash[key]}"}.join(", ")
    end

    def insync?(is)
      if defined? @should[0]
        if is == @should[0].each { |k, v| value[k] = to_type(v) }
          true
        else
          false
        end
      else
        true
      end
    end

    defaultto {}
  end
=end

  autorequire(:package) do
    ['sensu-cli']
  end

  autorequire(:service) do
    ['sensu-backend']
  end

  autorequire(:sensu_api_validator) do
    requires = []
    catalog.resources.each do |resource|
      if resource.class.to_s == 'Puppet::Type::Sensu_api_validator'
        requires << resource.name
      end
    end
    requires
  end

  validate do
    if !self[:command]
      self.fail "command must be defined"
    end
    if !self[:subscriptions] || self[:subscriptions].empty?
      self.fail "subscriptions must be defined"
    end
    if !self[:handlers] || self[:handlers].empty?
      self.fail "handlers must be defined"
    end
  end
end
