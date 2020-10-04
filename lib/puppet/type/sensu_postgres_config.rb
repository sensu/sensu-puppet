require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_postgres_config) do
  desc <<-DESC
@summary Manages Sensu postgres config
@example Create an PostgreSQL datastore
  sensu_postgres_config { 'puppet':
    ensure    => 'present',
    dsn       => 'postgresql://sensu:changeme@localhost:5432/sensu',
    pool_size => 20, 
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
    desc "The name of the postgres config"
  end

  newproperty(:dsn) do
    desc "Use the dsn attribute to specify the data source names as a URL or PostgreSQL connection string"

    def change_to_s(currentvalue, newvalue)
      return "changed dsn"
    end
    def is_to_s(currentvalue)
      return '[old dsn redacted]'
    end
    def should_to_s(newvalue)
      return '[new dsn redacted]'
    end
  end

  newproperty(:pool_size, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "The maximum number of connections to hold in the PostgreSQL connection pool"
    newvalues(/^[0-9]+$/)
    defaultto(0)
  end

  newproperty(:strict, :boolean => true) do
    desc "Perform configuration validation when configuring this resource"
    newvalues(:true, :false)
    defaultto(:false)
  end

  newproperty(:batch_buffer, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "Maximum number of requests to buffer in memory."
    newvalues(/^[0-9]+$/)
    defaultto(0)
  end

  newproperty(:batch_size, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "Number of requests in each PostgreSQL write transaction"
    newvalues(/^[0-9]+$/)
    defaultto(1)
  end

  newproperty(:batch_workers, :parent => PuppetX::Sensu::IntegerProperty) do
    desc "Number of requests in each PostgreSQL write transaction, defaults to value for pool_size"
    newvalues(/^[0-9]+$/)
    defaultto do
      @resource[:pool_size]
    end
  end

  def pre_run_check
    required_properties = [
      :dsn,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
  end
end
