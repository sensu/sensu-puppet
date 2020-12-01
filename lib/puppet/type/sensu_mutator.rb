require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/hash_of_strings_property'
require_relative '../../puppet_x/sensu/integer_property'
require_relative '../../puppet_x/sensu/secrets_property'

Puppet::Type.newtype(:sensu_mutator) do
  desc <<-DESC
@summary Manages Sensu mutators
@example Create a mutator
  sensu_mutator { 'example':
    ensure  => 'present',
    command => 'example-mutator.rb',
  }

@example Create a mutator with namespace `dev` in the name
  sensu_mutator { 'example in dev':
    ensure  => 'present',
    command => 'example-mutator.rb',
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
    The name of the mutator.
    The name supports composite names that can define the namespace.
    An example composite name to define resource named `test` in namespace `dev`: `test in dev`
    EOS
  end

  newparam(:resource_name, :namevar => true) do
    desc "The name of the mutator."
    validate do |value|
      unless value =~ PuppetX::Sensu::Type.name_regex
        raise ArgumentError, "sensu_mutator name invalid"
      end
    end
    defaultto do
      @resource[:name]
    end
  end

  newproperty(:command) do
    desc "The mutator command to be executed."
  end

  newproperty(:timeout, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "The mutator execution duration timeout in seconds (hard stop)"
    newvalues(/^[0-9]+$/, :absent)
  end

  newproperty(:runtime_assets, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "An array of Sensu assets (names), required at runtime for the execution of the command"
    newvalues(/.*/, :absent)
  end

  newproperty(:env_vars, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "An array of environment variables to use with command execution."
    newvalues(/.*/, :absent)
  end

  newproperty(:secrets, :array_matching => :all, :parent => PuppetX::Sensu::SecretsProperty) do
    desc <<-EOS
    Array of the name/secret pairs to use with command execution.
    Example: [{'name' => 'ANSIBLE_HOST', 'secret' => 'sensu-ansible-host' }]
    EOS
  end

  newproperty(:namespace, :namevar => true) do
    desc "The Sensu RBAC namespace that this mutator belongs to."
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
      :command,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
    PuppetX::Sensu::Type.validate_namespace(self)
  end
end
