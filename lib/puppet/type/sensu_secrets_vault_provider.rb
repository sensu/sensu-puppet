require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_secrets_vault_provider) do
  desc <<-DESC
@summary Manages Sensu Secrets provider
@example Manage a secrets vault provider
  sensu_secrets_vault_provider { 'my_vault-api':
    ensure       => 'present',
    address      => "https://vaultserver.example.com:8200",
    token        => "VAULT_TOKEN",
    version      => "v1",
    max_retries  => 2,
    timeout      => "20s",
    tls          => {
      "ca_cert" => "/etc/ssl/certs/ca-bundle.crt"
    },
    rate_limiter => {
      "limit" => 10,
      "burst" => 100
    },
  }

**NOTE** Property names map to the `client` hash in Sensu Go reference for a secrets VaultProvider

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensuctl_configure[puppet]`
* `Sensu_api_validator[sensu]`
* `Sensu_user[admin]`
DESC

  extend PuppetX::Sensu::Type
  add_autorequires(false)

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the secrets provider."
  end

  newproperty(:address) do
    desc 'Vault server address.'
  end

  newproperty(:token) do
    desc 'Vault token to use for authentication.'
    def change_to_s(currentvalue, newvalue)
      return "changed token"
    end
    def is_to_s(currentvalue)
      return '[old token redacted]'
    end
    def should_to_s(newvalue)
      return '[new token redacted]'
    end
  end

  newparam(:token_file) do
    desc 'Path to file that contains token to use for authentication.'
  end

  newproperty(:version) do
    desc 'HashiCorp Vault HTTP API version'
  end

  newproperty(:max_retries, :parent => PuppetX::Sensu::IntegerProperty) do
    desc 'Number of times to retry connecting to the vault provider.'
    defaultto(2)
  end

  newproperty(:timeout) do
    desc 'Provider connection timeout (hard stop).'
    defaultto('60s')
  end

  newproperty(:tls, :parent => PuppetX::Sensu::HashProperty) do
    desc 'TLS object. Vault only works with TLS configured.'
    defaultto(:absent)
    validate do |value|
      return if value == :absent
      super(value)
      valid_keys = ['ca_cert','ca_path','client_cert','client_key','cname','insecure','tls_server_name']
      value.keys.each do |key|
        if ! valid_keys.include?(key)
          raise ArgumentError, "#{key} is not a valid key for tls"
        end
      end
    end
    munge do |value|
      return value if value == :absent
      defaults = {
        'ca_cert' => '',
        'ca_path' => '',
        'client_cert' => '',
        'client_key' => '',
        'cname' => '',
        'insecure' => false,
        'tls_server_name' => '',
      }
      defaults.each_pair do |k, v|
        if ! value.key?(k)
          value[k] = v
        end
      end
      value
    end
  end

  newproperty(:rate_limiter, :parent => PuppetX::Sensu::HashProperty) do
    desc <<-EOS
    Keys:
    * limit - Maximum number of secrets requests per second that can be transmitted to the backend with the secrets API.
    * burst - Maximum amount of burst allowed in a rate interval for the secrets API.
    EOS
    defaultto(:absent)
    validate do |value|
      return if value == :absent
      super(value)
      valid_keys = ['limit','burst']
      value.keys.each do |key|
        if ! valid_keys.include?(key)
          raise ArgumentError, "#{key} is not a valid key for rate_limiter"
        end
        if ! value[key].is_a?(Integer)
          raise ArgumentError, "rate_limiter #{key} must be an Integer"
        end
      end
    end
    munge do |value|
      return value if value == :absent
      defaults = { 'limit' => 0, 'burst' => 0}
      defaults.each_pair do |k, v|
        if ! value.key?(k)
          value[k] = v
        end
      end
      value
    end
  end

  validate do
    required_properties = [
      :address,
      :version,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
    if self[:ensure] == :present && self[:token].nil? && self[:token_file].nil?
      fail "You must provide either token or token_file"
    end
    if self[:ensure] == :present && self[:token] && self[:token_file]
      fail "token and token_file are mutually exclusive"
    end
  end
end
