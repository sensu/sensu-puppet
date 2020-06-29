require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/hash_of_strings_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_filter) do
  desc <<-DESC
@summary Manages Sensu filters
@example Create a filter
  sensu_filter { 'test':
    ensure      => 'present',
    action      => 'allow',
    expressions => ["event.entity.labels.environment == 'production'"],
  }

@example Create a filter with namespace `dev` in the name
  sensu_filter { 'test in dev':
    ensure      => 'present',
    action      => 'allow',
    expressions => ["event.entity.labels.environment == 'production'"],
  }

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensuctl_configure[puppet]`
* `Sensu_api_validator[sensu]`
* `Sensu_user[admin]`
* `sensu_namespace` - Puppet will autorequire `sensu_namespace` resource defined in `namespace` property.
* `sensu_asset` - Puppet will autorequire `sensu_asset` resources defined in `runtime_assets` property.
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc <<-EOS
    The name of the filter.
    The name supports composite names that can define the namespace.
    An example composite name to define resource named `test` in namespace `dev`: `test in dev`
    EOS
  end

  newparam(:resource_name, :namevar => true) do
    desc "The name of the filter."
    validate do |value|
      unless value =~ PuppetX::Sensu::Type.name_regex
        raise ArgumentError, "sensu_filter name invalid"
      end
    end
    defaultto do
      @resource[:name]
    end
  end

  newproperty(:action) do
    desc "Action to take with the event if the filter expressions match."
    newvalues('allow', 'deny')
  end

  newproperty(:expressions, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "Filter expressions to be compared with event data."
  end

  newproperty(:runtime_assets, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "Assets to be applied to the filter's execution context."
    newvalues(/.*/, :absent)
  end

  newproperty(:namespace, :namevar => true) do
    desc "The Sensu RBAC namespace that this filter belongs to."
    defaultto 'default'
  end

  newproperty(:labels, :parent => PuppetX::Sensu::HashOfStringsProperty) do
    desc "Custom attributes to include with event data, which can be queried like regular attributes."
  end

  newproperty(:annotations, :parent => PuppetX::Sensu::HashOfStringsProperty) do
    desc "Arbitrary, non-identifying metadata to include with event data."
  end

  autorequire(:sensu_asset) do
    self[:runtime_assets]
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
      :action,
      :expressions
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
    PuppetX::Sensu::Type.validate_namespace(self)
  end
end
