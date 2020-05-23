require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_secret) do
  desc <<-DESC
@summary Manages Sensu Secrets
@example Manage a secret in the default namespace
  sensu_secret { 'sensu-ansible-token in default':
    ensure           => 'present',
    id               => 'ANSIBLE_TOKEN',
    secrets_provider => 'env',
  }

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensuctl_configure[puppet]`
* `Sensu_api_validator[sensu]`
* `Sensu_user[admin]`
* `sensu_namespace` - Puppet will autorequire `sensu_namespace` resource defined in `namespace` property.
DESC

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc <<-EOS
    The name of the secret.
    The name supports composite names that can define the namespace.
    An example composite name to define resource named `test` in namespace `dev`: `test in dev`
    EOS
  end

  newparam(:resource_name, :namevar => true) do
    desc "The name of the secret."
    defaultto do
      @resource[:name]
    end
  end

  newproperty(:id) do
    desc 'The identifying key for the provider to retrieve the secret.'
  end

  newproperty(:secrets_provider) do
    desc 'The name of the Sensu provider with the secret.'
  end

  newproperty(:namespace, :namevar => true) do
    desc "The Sensu RBAC namespace that this secret belongs to."
    defaultto 'default'
  end

  autorequire(:sensu_secrets_vault_provider) do
    [ self[:secrets_provider] ]
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
      :id,
      :secrets_provider,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
    PuppetX::Sensu::Type.validate_namespace(self)
  end
end
