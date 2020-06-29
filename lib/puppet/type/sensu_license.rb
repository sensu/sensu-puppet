require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_license) do
  desc <<-DESC
@summary Manage a sensu license
**NOTE** This is a private type not intended to be used directly.

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensu_api_validator[sensu]`
* `Sensu_user[admin]`
* `file` - Puppet will autorequire `file` resources defined in `file` property.
DESC

  extend PuppetX::Sensu::Type
  add_autorequires(false, false)

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the resource."
  end

  newparam(:file) do
    desc "Path to license file"
  end

  autorequire(:file) do
    [ self[:file] ]
  end

  def refresh
    if (@parameters[:ensure] || newattr(:ensure)).retrieve == :present
      provider.create
    end
  end

  validate do
    if self[:file].nil?
      fail "You must provide file parameter"
    end
  end
end
