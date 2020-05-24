require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensuctl_configure) do
  desc <<-DESC
@summary Manages 'sensuctl configure'
**NOTE** This is a private type not intended to be used directly.

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensu_api_validator[sensu]`
* `Sensu_user[admin]`
* `file` - Puppet will autorequire `file` resources defined in `trusted_ca_file` property.
DESC

  extend PuppetX::Sensu::Type
  add_autorequires(false, false)

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the resource."
  end

  newproperty(:url) do
    desc "sensu-backend URL"
  end

  newparam(:username) do
    desc "Username to use with sensuctl configure"
  end

  newparam(:password) do
    desc "Password to use with sensuctl configure"
  end

  newproperty(:trusted_ca_file) do
    desc "Path to trusted CA"
    defaultto('/etc/sensu/ssl/ca.crt')
  end

  newproperty(:config_format) do
    desc "Set configured format for sensuctl"
    newvalues('tabular','json','wrapped-json','yaml')
    munge do |value|
      value.to_s
    end
  end

  newproperty(:config_namespace) do
    desc "Set configured namespace for sensuctl"
  end

  autorequire(:file) do
    if self[:trusted_ca_file] && self[:trusted_ca_file] != 'absent'
      [ self[:trusted_ca_file] ]
    end
  end

  validate do
    required_properties = [
      :url,
      :username,
      :password,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
  end
end
