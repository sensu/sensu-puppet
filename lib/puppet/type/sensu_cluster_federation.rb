require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_cluster_federation) do
  desc <<-DESC
@summary Manages Sensu clusters federation
@example Create a federated cluster
  sensu_cluster_federation { 'us-west-2a':
    ensure    => 'present',
    api_urls  => ['http://10.0.0.1:8080','http://10.0.0.2:8080','http://10.0.0.3:8080'],
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
    desc "The name of the federated cluster"
  end

  newproperty(:api_urls, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc "Federated cluster backend API URLs"
  end

  def pre_run_check
    required_properties = [
      :api_urls,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
  end
end
