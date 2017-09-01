require File.expand_path(File.join(File.dirname(__FILE__), '..', '..',
                                   'puppet_x', 'sensu', 'boolean_property.rb'))

Puppet::Type.newtype(:sensu_enterprise_dashboard_api_config) do
  @doc = "Manages Sensu Enterprise Dashboard API config"

  def initialize(*args)
    super *args
    # N.B. catalog will return `nil` when running in the context of `puppet
    # resource`.  We must take care not to call methods on a nil object.
    if c = catalog
      # Notify the service if it exists in the catalog.
      id = 'Service[sensu-enterprise-dashboard]'
      self[:notify] = [c.resource(id)].compact
    end
  end

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto :present
  end

  newparam(:host) do
    desc "The hostname or IP address of the Sensu API."

    isnamevar
  end

  newparam(:base_path) do
    desc "The base path to the client config file"
    defaultto '/etc/sensu/'
  end

  newproperty(:datacenter) do
    desc "The name of the Sensu API (used elsewhere as the datacenter name)."
  end

  newproperty(:port) do
    desc "The port of the Sensu API."

    newvalues(/[0-9]+/)

    defaultto '4567'
  end

  newproperty(:ssl, :parent => PuppetX::Sensu::BooleanProperty) do
    desc "Determines whether or not to use the HTTPS protocol."

    defaultto :false
  end

  newproperty(:insecure, :parent => PuppetX::Sensu::BooleanProperty) do
    desc "Determines whether or not to accept an insecure SSL certificate."

    defaultto :false
  end

  newproperty(:path) do
    desc "The path of the Sensu API. Leave empty unless your Sensu API is not mounted to /."
  end

  newproperty(:timeout) do
    desc "The timeout for the Sensu API, in seconds."

    newvalues(/[0-9]+/)

    defaultto '5'
  end

  newproperty(:user) do
    desc "The username of the Sensu API. Leave empty for no authentication."

    newvalues(/.+/)
  end

  newproperty(:pass) do
    desc "The password of the Sensu API. Leave empty for no authentication."

    newvalues(/.+/)
  end

  autorequire(:package) do
    ['sensu-enterprise-dashboard']
  end
end
