require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_tessen) do
  desc <<-DESC
@summary Manages Sensu Tessen - This is a private type
@api private

**Autorequires**:
* `Package[sensu-go-cli]`
* `Service[sensu-backend]`
* `Sensu_configure[puppet]`
* `Sensu_api_validator[sensu]`
DESC

  extend PuppetX::Sensu::Type
  add_autorequires(false)

  ensurable do
    desc "State of tessen"
    nodefault
    newvalue(:present) do
      @resource.provider.create
    end
    newvalue(:absent) do
      @resource.provider.destroy
    end
    def retrieve
      @resource.provider.state || :absent
    end
  end

  newparam(:name, :namevar => true) do
    desc "Resource name"
  end
end
