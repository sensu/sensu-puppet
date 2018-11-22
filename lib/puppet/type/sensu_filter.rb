require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_filter) do
  desc <<-DESC
@summary Manages Sensu filters
@example Create a filter
  sensu_filter { 'test':
    ensure      => 'present',
    action      => 'allow',
    expressions => ["event.Entity.Environment == 'production'"],
    when_days   => {'all' => [{'begin' => '5:00 PM', 'end' => '8:00 AM'}]},
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
    desc "The name of the filter."
    validate do |value|
      unless value =~ /^[\w\.\-]+$/
        raise ArgumentError, "sensu_filter name invalid"
      end
    end
  end

  newproperty(:action) do
    desc "Action to take with the event if the filter expressions match."
    newvalues('allow', 'deny')
  end

  newproperty(:expressions, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "Filter expressions to be compared with event data."
  end

  newproperty(:when_days, :parent => PuppetX::Sensu::HashProperty) do
    desc "A hash of days of the week (i.e., monday) and/or all. Each day specified can define one or more time windows, in which the filter is applied."
    validate do |value|
      super(value)
      value.each_pair do |k,v|
        if ! ['monday','tuesday','wednesday','thursday','friday','saturday','sunday','all'].include?(k.to_s)
          raise ArgumentError, "when_days keys must be day of the week or 'all', not #{k}"
        end
        if ! v.is_a?(Array)
          raise ArgumentError, "when_days hash values must be an Array"
        end
        v.each do |d|
          if ! d.is_a?(Hash) || ! d.key?('begin') || ! d.key?('end')
            raise ArgumentError, "when_days day time window must be a hash containing keys 'begin' and 'end'"
          end
        end
      end
    end
  end

  newproperty(:runtime_assets, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "Assets to be applied to the filter’s execution context."
    newvalues(/.*/, :absent)
  end

  newproperty(:namespace) do
    desc "The Sensu RBAC namespace that this filter belongs to."
    defaultto 'default'
  end

  validate do
    required_properties = [
      :action,
      :expressions
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
  end
end
