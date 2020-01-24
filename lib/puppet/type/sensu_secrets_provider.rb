require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_secrets_provider) do
  desc <<-DESC
@summary Manages Sensu Secrets provider
@example Manage a secrets vault provider
  sensu_secrets_provider { 'my_vault-api':
    ensure        => 'present',
    type => 'VaultProvider',
    client        => {
      "address"      => "https://vaultserver.example.com:8200",
      "token"        => "VAULT_TOKEN",
      "version"      => "v1",
      "max_retries"  => 2,
      "timeout"      => "20s",
      "tls"          => {
        "ca_cert" => "/etc/ssl/certs/ca-bundle.crt"
      },
      "rate_limiter" => {
        "limit" => 10,
        "burst" => 100
      },
    },
  }

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensuctl_configure[puppet]`
* `Sensu_api_validator[sensu]`
DESC

  extend PuppetX::Sensu::Type
  add_autorequires(false)

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the secrets provider."
  end

  newparam(:type) do
    desc "The type of secrets provider"
    newvalues('VaultProvider', 'Env')
    defaultto('VaultProvider')
    munge { |v| v.to_s }
  end

  newproperty(:client, :parent => PuppetX::Sensu::HashProperty) do
    desc <<-EOS
    Map that includes secrets provider configuration

    Keys:
    * address: Required
    * token: Required
    * version: Required
    * tls (Hash): Optional
    * max_retries: Number of times to retry connecting to the vault provider. Default to 2
    * timeout: Provider connection timeout (hard stop). Default to 60s
    * rate_limiter (Hash): Maximum rate and burst limits for the secrets API. Optional
    
    tls keys:
    * ca_cert
    * ca_path
    * client_cert
    * client_key
    * cname
    * insecure
    * tls_server_name

    rate_limiter keys:
    * limit
    * burst
    EOS
    validate do |client|
      super(client)
      required_keys = ['address','token','version']
      client_keys = client.keys.map { |k| k.to_s }
      required_keys.each do |k|
        if ! client_keys.include?(k)
          raise ArgumentError, "client requires key #{k}"
        end
      end
      if client.key?('tls')
        if ! client['tls'].is_a?(Hash)
          raise ArgumentError, "client tls must be a Hash not #{client['tls'].class}"
        end
        tls_valid_keys = ['ca_cert','ca_path','client_cert','client_key','cname','insecure','tls_server_name']
        client['tls'].keys.each do |key|
          if ! tls_valid_keys.include?(key)
            raise ArgumentError, "#{key} is not a valid key for tls"
          end
        end
      end
      if client.key?('rate_limiter')
        if ! client['rate_limiter'].is_a?(Hash)
          raise ArgumentError, "client rate_limiter must be a Hash not #{client['rate_limiter'].class}"
        end
        rate_valid_keys = ['limit','burst']
        client['rate_limiter'].keys.each do |key|
          if ! rate_valid_keys.include?(key)
            raise ArgumentError, "#{key} is not a valid key for rate_limiter"
          end
          if ! client['rate_limiter'][key].is_a?(Integer)
            raise ArgumentError, "rate_limiter #{key} must be an Integer"
          end
        end
      end
      valid_keys = required_keys + ['tls','max_retries','timeout','rate_limiter','agent_address']
      client.keys.each do |key|
        if ! valid_keys.include?(key)
          raise ArgumentError, "#{key} is not a valid key for client"
        end
      end
    end
    munge do |client|
      if client.key?('tls')
        tls_defaults = {
          'ca_cert' => '',
          'ca_path' => '',
          'client_cert' => '',
          'client_key' => '',
          'cname' => '',
          'insecure' => false,
          'tls_server_name' => '',
        }
        tls_defaults.each_pair do |tls_key, value|
          if ! client['tls'].key?(tls_key)
            client['tls'][tls_key] = value
          end
        end
      else
        client['tls'] = nil
      end
      if client.key?('rate_limiter')
        rate_defaults = { 'limit' => 0, 'burst' => 0}
        rate_defaults.each_pair do |key, value|
          if ! client['rate_limiter'].key?(key)
            client['rate_limiter'][key] = value
          end
        end
      else
        client['rate_limiter'] = nil
      end
      defaults = {
        'max_retries' => 2,
        'timeout' => '60s',
        'agent_address' => '',
      }
      defaults.each_pair do |key, value|
        if ! client.key?(key)
          client[key] = value
        end
      end
      client
    end
  end

  validate do
    if self[:ensure] == :present
      if self[:type] == 'VaultProvider' && self[:client].nil?
        fail 'You must provider client property for type VaultProvider'
      end
    end
  end
end
