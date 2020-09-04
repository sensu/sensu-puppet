require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_user) do
  desc <<-DESC
@summary Manages Sensu users
@example Create a user
  sensu_user { 'test':
    ensure   => 'present',
    password => 'supersecret',
    groups   => ['users'],
  }

@example Change a user's password
  sensu_user { 'test'
    ensure   => 'present',
    password => 'newpassword',
    groups   => ['users'],
  }

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensuctl_configure[puppet]`
* `Sensu_api_validator[sensu]`
* `Sensu_user[admin]`
DESC

  extend PuppetX::Sensu::Type
  add_autorequires(false, true, false)

  ensurable do
    desc "The basic property that the resource should be in."
    defaultvalues
    validate do |value|
      if value.to_sym == :absent
        raise ArgumentError, "sensu_user ensure does not support absent"
      end
    end
  end

  newparam(:name, :namevar => true) do
    desc "The name of the user."
    validate do |value|
      # Match only upper case letters, lowercase letters, numbers, underscores, periods and hyphens
      unless value =~ %r{^[\w.\-]+$}
        raise ArgumentError, "sensu_user name invalid"
      end
    end
  end

  newproperty(:password) do
    desc "The user's password."

    validate do |value|
      raise ArgumentError, "password must be at least 8 characters long" unless value.size >= 8
    end

    def insync?(is)
      if @resource[:disabled].to_sym == :true
        return true
      end
      if @resource.provider
        if @resource.provider.disabled.to_sym == :true
          return true
        end
        @resource.provider.password_insync?(@resource[:name], @should)
      end
    end

    def change_to_s(currentvalue, newvalue)
      return "changed password"
    end
    def is_to_s(currentvalue)
      return '[old password redacted]'
    end
    def should_to_s(newvalue)
      return '[new password redacted]'
    end
  end

  newproperty(:groups, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "Groups to which the user belongs."
  end

  newproperty(:disabled, :boolean => true) do
    desc "The state of the user's account."
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:configure, :boolean => true) do
    desc "Run sensuctl configure for this user"
    newvalues(:true, :false)
    defaultto :false
  end

  newparam(:configure_url) do
    desc "URL to use with 'sensuctl configure'"
    defaultto 'http://127.0.0.1:8080'
  end

  newparam(:configure_trusted_ca_file) do
    desc "Path to trusted CA to use with 'sensuctl configure'"
    defaultto('/etc/sensu/ssl/ca.crt')
  end

  autorequire(:sensu_user) do
    if self[:name] == 'admin'
      []
    else
      ['admin']
    end
  end

  validate do
    required_properties = [
      :password
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
  end
end
