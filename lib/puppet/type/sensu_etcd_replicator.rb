require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_etcd_replicator) do
  desc <<-DESC
@summary Manages Sensu etcd replicators
@example Create an Etcd Replicator
  sensu_etcd_replicator { 'role_replicator':
    ensure                       => 'present',
    ca_cert                      => '/path/to/ssl/trusted-certificate-authorities.pem',
    cert                         => '/path/to/ssl/cert.pem',
    key                          => '/path/to/ssl/key.pem',
    insecure                     => false,
    url                          => 'http://127.0.0.1:2379',
    api_version                  => 'core/v2',
    resource_name                => 'Role',
    replication_interval_seconds => 30,
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
    desc "The name of the Etcd Replicator."
  end

  newproperty(:ca_cert) do
    desc "Path to an the PEM-format CA certificate to use for TLS client authentication."
  end

  newproperty(:cert) do
    desc "Path to the PEM-format certificate to use for TLS client authentication."
  end

  newproperty(:key) do
    desc "Path to the PEM-format key file associated with the cert to use for TLS client authentication."
  end

  newproperty(:insecure, :boolean => true) do
    desc "true to disable transport security."
    newvalues(:true, :false)
    defaultto(:false)
  end

  newproperty(:url) do
    desc "Destination cluster URL. If specifying more than one, use a comma to separate."
  end

  newproperty(:api_version) do
    desc "Sensu API version of the resource to replicate"
    defaultto('core/v2')
  end

  newproperty(:resource_name) do
    desc "Name of the resource to replicate"
  end

  newproperty(:namespace) do
    desc "Namespace to constrain replication to. If you do not include namespace, all namespaces for a given resource are replicated."
    munge do |value|
      "" if value.nil?
    end
  end

  newproperty(:replication_interval_seconds, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "The interval at which the resource will be replicated"
    newvalues(/^[0-9]+$/, :absent)
    defaultto(30)
  end

  def pre_run_check
    required_properties = [
      :url,
      :resource_name,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
    if self[:ensure] == :present
      if self[:insecure].to_sym == :false
        [
          :ca_cert,
          :cert,
          :key,
        ].each do |property|
          if self[property].nil?
            fail "#{PuppetX::Sensu::Type.error_prefix(self)} #{property} is required when insecure is false"
          end
        end
      end
    end
  end
end
