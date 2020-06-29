require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_cluster_member) do
  desc <<-DESC
@summary Manages Sensu cluster members
@example Add a cluster member
  sensu_cluster_member { 'backend2':
    ensure    => 'present',
    peer_urls => ['http://192.168.52.12:2380'],
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
    desc "The name of the cluster member."
  end

  newproperty(:peer_urls, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "Array of cluster peer URLs"
  end

  newparam(:id) do
    desc "Cluster member ID - read-only"
    validate do |value|
      fail "id is read-only"
    end
  end

  validate do
    required_properties = [
      :peer_urls,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
  end
end
