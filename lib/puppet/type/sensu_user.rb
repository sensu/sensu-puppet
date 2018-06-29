require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_user) do
  @doc = "Manages Sensu users"

  extend PuppetX::Sensu::Type
  add_autorequires()

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the user."
    validate do |value|
      unless value =~ /^[\w\.\-]+$/
        raise ArgumentError, "sensu_user name invalid"
      end
    end
  end

  newproperty(:password) do
    desc "The user's password."

    def insync(is)
      if @resource.provider
        @resource.provider.password_insync?
      end
    end

    def change_to_s(currentvalue, newvalue)
      if currentvalue == :absent
        return "created passwod"
      else
        return "changed password"
      end
    end
    def is_to_s(currentvalue)
      return '[old password redacted]'
    end
    def should_to_s(newvalue)
      return '[new password redacted]'
    end
  end

  newproperty(:roles, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "A list of roles the user belongs to."
  end

  newproperty(:disabled, :boolean => true) do
    desc "The state of the user’s account."
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
