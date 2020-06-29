require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_cluster_federation_member) do
  desc <<-DESC
@summary Manages Sensu clusters federation member
@example Add to a federated cluster
  sensu_cluster_federation_member { 'http://10.0.0.1:8080':
    ensure   => 'present',
    cluster  => 'us-west-2a',
  }

@example Add to a federated cluster to `us-west-2a` cluster using composite name
  sensu_cluster_federation_member { 'http://10.0.0.1:8080 in us-west-2a':
    ensure => 'present',
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
    desc "The name of the resource"
  end

  newparam(:cluster, :namevar => true) do
    desc "Federated cluster name"
  end

  newparam(:api_url, :namevar => true) do
    desc "API URL to add to the federated cluster, defaults to name"
    defaultto { @resource[:name] }
  end

  def self.title_patterns
    [
      [
        /^((\S+) in (\S+))$/,
        [
          [:name],
          [:api_url],
          [:cluster],
        ],
      ],
      [
        /(.*)/,
        [
          [:name],
        ],
      ],
    ]
  end

  def pre_run_check
    required_properties = [
      :cluster,
    ]
    required_properties.each do |property|
      if self[property].nil?
        fail "You must provide a #{property}"
      end
    end
  end
end
