require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_ad_auth) do
  desc <<-DESC
@summary Manages Sensu AD auth.
@example Add a AD auth
  sensu_ldap_auth { 'ad':
    ensure              => 'present',
    servers             => [
      {
        'host' => '127.0.0.1',
        'port' => 389,
        'binding' => {
          'user_dn' => 'cn=binder,dc=acme,dc=org',
          'password' => 'P@ssw0rd!'
        },
        'group_search' => {
          'base_dn' => 'dc=acme,dc=org',
        },
        'user_search'  => {
          'base_dn' => 'dc=acme,dc=org',
        },
      },
    ],
  }

@example Add an AD auth that uses memberOf attribute by omitting group_search
  sensu_ldap_auth { 'ad':
    ensure              => 'present',
    servers             => [
      {
        'host' => '127.0.0.1',
        'port' => 389,
        'binding' => {
          'user_dn' => 'cn=binder,dc=acme,dc=org',
          'password' => 'P@ssw0rd!'
        },
        'user_search'  => {
          'base_dn' => 'dc=acme,dc=org',
        },
      },
    ],
  }


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
    desc "The name of the AD auth."
    validate do |value|
      unless value =~ PuppetX::Sensu::Type.name_regex
        raise ArgumentError, "sensu_ad_auth name invalid"
      end
    end
  end

  newproperty(:servers, :array_matching => :all, :parent => PuppetX::Sensu::ArrayOfHashesProperty) do
    desc <<-EOS
    AD servers as Array of Hashes

    Keys:
    * host: required
    * port: required
    * group_search: optional (omit to use memberOf)
    * user_search: required
    * binding: optional Hash
    * insecure: default is `false`
    * security: default is `tls`
    * trusted_ca_file: default is `""`
    * client_cert_file: default is `""`
    * client_key_file: default is `""`
    * default_upn_domain: default is `""`
    * include_nested_groups: Boolean

    group_search keys:
    * base_dn: required
    * attribute: default is `member`
    * name_attribute: default is `cn`
    * object_class: default is `group`

    user_search Keys:
    * base_dn: required
    * attribute: default is `sAMAccountName`
    * name_attribute: default is `displayName`
    * object_class: default is `person`

    binding keys:
    * user_dn: required
    * password: required
    EOS
    validate do |server|
      if ! server.is_a?(Hash)
        raise ArgumentError, "Each server must be a Hash not #{server.class}"
      end
      required_keys = ['host','port','user_search']
      server_keys = server.keys.map { |k| k.to_s }
      required_keys.each do |k|
        if ! server_keys.include?(k)
          raise ArgumentError, "server requires key #{k}"
        end
      end
      if ! server['port'].is_a?(Integer)
        raise ArgumentError, "server port must be an Integer not #{server['port'].class}"
      end
      if server.key?('insecure') && ! [TrueClass,FalseClass].include?(server['insecure'].class)
        raise ArgumentError, "server insecure must be a Boolean"
      end
      if server.key?('security') && ! ['tls','starttls','insecure'].include?(server['security'].to_s)
        raise ArgumentError, "server security must be tls, starttls or insecure, not #{server['security']}"
      end
      if server.key?('include_nested_groups') && ! [TrueClass,FalseClass].include?(server['include_nested_groups'].class)
        raise ArgumentError, "server include_nested_groups must be a Boolean"
      end
      if server.key?('binding')
        if ! server['binding'].is_a?(Hash)
          raise ArgumentError, "server binding must be a hash, not #{server['binding'].class}"
        end
        if server['binding'].keys.sort != ['password','user_dn']
          raise ArgumentError, "server binding must contain keys 'password' and 'user_dn'"
        end
      end
      if server.key?('group_search')
        if ! server['group_search'].is_a?(Hash)
          raise ArgumentError, "group_search must be a Hash not #{server['group_search'].class}"
        end
        if ! server['group_search'].key?('base_dn')
          raise ArgumentError, "group_search requires base_dn"
        end
        group_search_valid_keys = ['base_dn','attribute','name_attribute','object_class']
        server['group_search'].keys.each do |key|
          if ! group_search_valid_keys.include?(key)
            raise ArgumentError, "#{key} is not a valid key for group_search"
          end
        end
      end
      if ! server['user_search'].is_a?(Hash)
        raise ArgumentError, "user_search must be a Hash not #{server['user_search'].class}"
      end
      if ! server['user_search'].key?('base_dn')
        raise ArgumentError, "user_search requires base_dn"
      end
      user_search_valid_keys = ['base_dn','attribute','name_attribute','object_class']
      server['user_search'].keys.each do |key|
        if ! user_search_valid_keys.include?(key)
          raise ArgumentError, "#{key} is not a valid key for user_search"
        end
      end
      valid_keys = ['host','port','insecure','security','trusted_ca_file','client_cert_file','client_key_file',
        'default_upn_domain','include_nested_groups',
        'binding','group_search','user_search']
      server.keys.each do |key|
        if ! valid_keys.include?(key)
          raise ArgumentError, "#{key} is not a valid key for server"
        end
      end
    end
    munge do |server|
      if ! server.key?('insecure')
        server['insecure'] = false
      end
      if ! server.key?('security')
        server['security'] = 'tls'
      end
      ['trusted_ca_file','client_cert_file','client_key_file','default_upn_domain'].each do |k|
        if ! server.key?(k)
          server[k] = ''
        end
      end
      if server.key?('group_search')
        group_search_defaults = {
          'attribute' => 'member',
          'name_attribute' => 'cn',
          'object_class' => 'group',
        }
        group_search_defaults.each_pair do |k,v|
          if ! server['group_search'].key?(k)
            server['group_search'][k] = v
          end
        end
      else
        server['group_search'] = {
          'base_dn' => '',
          'attribute' => '',
          'name_attribute'  => '',
          'object_class'    => '',
        }
      end
      user_search_defaults = {
        'attribute' => 'sAMAccountName',
        'name_attribute' => 'displayName',
        'object_class' => 'person',
      }
      user_search_defaults.each_pair do |k,v|
        if ! server['user_search'].key?(k)
          server['user_search'][k] = v
        end
      end
      server
    end

    def change_to_s(currentvalue, newvalue)
      currentv = currentvalue.to_s
      if currentvalue.is_a?(Array)
        currentvalue.each_with_index do |c,i|
          if c.key?('binding')
            currentv.gsub!(currentvalue[i]['binding']['password'], '*****')
          end
        end
      end
      newv = newvalue.to_s
      if newvalue.is_a?(Array)
        newvalue.each_with_index do |n,i|
          if n.key?('binding')
            newv.gsub!(newvalue[i]['binding']['password'], '****')
          end
        end
      end
      super(currentv, newv)
    end

    def is_to_s(currentvalue)
      currentv = currentvalue.to_s
      if currentvalue.is_a?(Array)
        currentvalue.each_with_index do |c,i|
          if c.key?('binding')
            currentv.gsub!(currentvalue[i]['binding']['password'], '*****')
          end
        end
      end
      currentv
    end
    alias :should_to_s :is_to_s
  end

  newproperty(:groups_prefix) do
    desc 'The prefix added to all LDAP groups.'
  end

  newproperty(:username_prefix) do
    desc 'The prefix added to all LDAP usernames.'
  end

  validate do
    required_properties = [
      :servers,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
  end
end
