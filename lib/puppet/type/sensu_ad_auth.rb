require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_ad_auth) do
  desc <<-DESC
@summary Manages Sensu Active Directory auth. Requires valid enterprise license.
@example Add an Active Directory auth
  sensu_ad_auth { 'ad':
    ensure              => 'present',
    servers             => [
      {
        'host' => '127.0.0.1',
        'port' => 636,
      },
    ],
    server_binding      => {
      '127.0.0.1' => {
        'user_dn' => 'cn=binder,dc=acme,dc=org',
        'password' => 'P@ssw0rd!'
      }
    },
    server_group_search => {
      '127.0.0.1' => {
        'base_dn' => 'dc=acme,dc=org',
      }
    },
    server_user_search  => {
      '127.0.0.1' => {
        'base_dn' => 'dc=acme,dc=org',
      }
    },
  }

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensu_configure[puppet]`
* `Sensu_api_validator[sensu]`
* `Exec[sensu-add-license]`
DESC

  extend PuppetX::Sensu::Type
  add_autorequires(false)

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the AD auth."
    validate do |value|
      unless value =~ /^[\w\.\-]+$/
        raise ArgumentError, "sensu_ad_auth name invalid"
      end
    end
  end

  newproperty(:servers, :array_matching => :all, :parent => PuppetX::Sensu::ArrayOfHashesProperty) do
    desc <<-EOS
    AD servers
    Defaults:
    * insecure: false
    * security: tls
    EOS
    validate do |server|
      if ! server.is_a?(Hash)
        raise ArgumentError, "Each server must be a Hash not #{server.class}"
      end
      required_keys = ['host','port']
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
      valid_keys = ['host','port','insecure','security']
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
      server
    end
  end

  newproperty(:server_binding, :parent => PuppetX::Sensu::HashProperty) do
    desc "AD server bindings"
    validate do |bindings|
      super(bindings)
      bindings.each_pair do |server,binding|
        if ! binding.is_a?(Hash)
          raise ArgumentError, "binding must be a Hash not #{binding.class}"
        end
        if ! binding.key?('user_dn')
          raise ArgumentError, "binding requires user_dn"
        end
        if ! binding.key?('password')
          raise ArgumentError, "binding requires password"
        end
        valid_keys = ['user_dn','password']
        binding.keys.each do |key|
          if ! valid_keys.include?(key)
            raise ArgumentError, "#{key} is not a valid key for binding"
          end
        end
      end
    end
    
    def change_to_s(currentvalue, newvalue)
      return "changed server bindings"
    end
    def is_to_s(currentvalue)
      return '[old server bindings redacted]'
    end
    def should_to_s(newvalue)
      return '[new server bindings redacted]'
    end
  end

  newproperty(:server_group_search, :parent => PuppetX::Sensu::HashProperty) do
    desc <<-EOS
    Search configuration for groups.
    Defaults:
    * attribute: member
    * name_attribute: cn
    * object_class: group
    EOS
    validate do |server_group_search|
      super(server_group_search)
      server_group_search.each_pair do |server, group_search|
        if ! group_search.is_a?(Hash)
          raise ArgumentError, "group_search must be a Hash not #{group_search.class}"
        end
        if ! group_search.key?('base_dn')
          raise ArgumentError, "group_search requires base_dn"
        end
        valid_keys = ['base_dn','attribute','name_attribute','object_class']
        group_search.keys.each do |key|
          if ! valid_keys.include?(key)
            raise ArgumentError, "#{key} is not a valid key for group_search"
          end
        end
      end
    end
    munge do |server_group_search|
      n = {}
      defaults = {
        'attribute' => 'member',
        'name_attribute' => 'cn',
        'object_class' => 'group',
      }
      server_group_search.each_pair do |server, group_search|
        defaults.each_pair do |k,v|
          if ! group_search.key?(k)
            group_search[k] = v
          end
        end
        n[server] = group_search
      end
      n
    end
  end

  newproperty(:server_user_search, :parent => PuppetX::Sensu::HashProperty) do
    desc <<-EOS
    Search configuration for users.
    Defaults:
    * attribute: sAMAccountName
    * name_attribute: displayName
    * object_class: person
    EOS
    validate do |server_user_search|
      super(server_user_search)
      server_user_search.each_pair do |server, user_search|
        if ! user_search.is_a?(Hash)
          raise ArgumentError, "user_search must be a Hash not #{user_search.class}"
        end
        if ! user_search.key?('base_dn')
          raise ArgumentError, "user_search requires base_dn"
        end
        valid_keys = ['base_dn','attribute','name_attribute','object_class']
        user_search.keys.each do |key|
          if ! valid_keys.include?(key)
            raise ArgumentError, "#{key} is not a valid key for user_search"
          end
        end
      end
    end
    munge do |server_user_search|
      n = {}
      defaults = {
        'attribute' => 'sAMAccountName',
        'name_attribute' => 'displayName',
        'object_class' => 'person',
      }
      server_user_search.each_pair do |server, user_search|
        defaults.each_pair do |k,v|
          if ! user_search.key?(k)
            user_search[k] = v
          end
        end
        n[server] = user_search
      end
      n
    end
  end

  newproperty(:groups_prefix) do
    desc 'The prefix added to all AD groups.'
  end

  newproperty(:username_prefix) do
    desc 'The prefix added to all AD usernames.'
  end

  autorequire(:exec) do
    [ 'sensu-add-license' ]
  end

  validate do
    required_properties = [
      :servers,
      :server_binding,
      :server_group_search,
      :server_user_search,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
    if self[:ensure] == :present
      servers = self[:servers].map { |s| s['host'] }.sort
      self[:server_binding].keys.each do |server|
        if ! servers.include?(server)
          fail "Server binding for #{server} not found in servers property"
        end
      end
      self[:server_group_search].keys.each do |server|
        if ! servers.include?(server)
          fail "Server group_search for #{server} not found in servers property"
        end
      end
      self[:server_user_search].keys.each do |server|
        if ! servers.include?(server)
          fail "Server user_search for #{server} not found in servers property"
        end
      end
      servers.each do |server|
        if ! self[:server_binding].keys.include?(server)
          fail "server #{server} has no binding defined"
        end
        if ! self[:server_group_search].keys.include?(server)
          fail "server #{server} has no group_search defined"
        end
        if ! self[:server_user_search].keys.include?(server)
          fail "server #{server} has no user_search defined"
        end
      end
    end
  end
end
