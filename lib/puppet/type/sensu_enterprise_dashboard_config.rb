Puppet::Type.newtype(:sensu_enterprise_dashboard_config) do
  @doc = "Manages Sensu Enterprise Dashboard config"

  def initialize(*args)
    super *args

    self[:notify] = [
      "Service[sensu-enterprise-dashboard]",
    ].select { |ref| catalog.resource(ref) }
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

  newparam(:name) do
    desc "This value has no effect, set it to what ever you want."
  end

  newparam(:base_path) do
    desc "The base path to the client config file"
    defaultto '/etc/sensu/'
  end

  newproperty(:host) do
    desc "The hostname or IP address on which Sensu Enterprise Dashboard will listen on."

    defaultto '0.0.0.0'
  end

  newproperty(:port) do
    desc "The port on which Sensu Enterprise Dashboard will listen on."

    defaultto '3000'
  end

  newproperty(:refresh) do
    desc "Determines the interval to poll the Sensu APIs, in seconds."

    defaultto '5'
  end

  newproperty(:user) do
    desc "A username to enable simple authentication and restrict access to the dashboard. Leave blank along with pass to disable simple authentication."
  end

  newproperty(:pass) do
    desc "A password to enable simple authentication and restrict access to the dashboard. Leave blank along with user to disable simple authentication."
  end

  newproperty(:auth) do
    desc "The auth definition scope, used to configure JSON Web Token (JWT) authentication signatures."

    validate do |value|
      unless value.respond_to?(:to_hash)
        raise ArgumentError, "Sensu Enterprise Dashboard auth config must be a Hash"
      end
    end
  end

  newproperty(:ssl) do
    desc "A hash of SSL attributes to enable native SSL"

    validate do |value|
      unless value.respond_to?(:to_hash)
        raise ArgumentError, "Sensu Enterprise Dashboard ssl config must be a Hash"
      end
    end
  end

  newproperty(:audit) do
    desc "A hash of audit attributes to enable audit logging"

    validate do |value|
      unless value.respond_to?(:to_hash)
        raise ArgumentError, "Sensu Enterprise Dashboard audit config must be a Hash"
      end
    end
  end

  newproperty(:github) do
    desc "A hash of GitHub authentication attributes to enable GitHub authentication via OAuth. Overrides simple authentication."

    validate do |value|
      unless value.respond_to?(:to_hash)
        raise ArgumentError, "Sensu Enterprise Dashboard github config must be a Hash"
      end
    end
  end

  newproperty(:gitlab) do
    desc "A hash of GitLab authentication attributes to enable GitLab authentication via OAuth. Overrides simple authentication."

    validate do |value|
      unless value.respond_to?(:to_hash)
        raise ArgumentError, "Sensu Enterprise Dashboard gitlab config must be a Hash"
      end
    end
  end

  newproperty(:ldap) do
    desc "A hash of Lightweight Directory Access Protocol (LDAP) authentication attributes to enable LDAP authentication. Overrides simple authentication."

    validate do |value|
      unless value.respond_to?(:to_hash)
        raise ArgumentError, "Sensu Enterprise Dashboard LDAP config must be a Hash"
      end
    end
  end

  newproperty(:oidc) do
    desc "The oidc definition scope, used to configure Role Based Access Controls with the RBAC for OpenID Connect (OIDC) driver. Overrides simple authentication."

    validate do |value|
      unless value.respond_to?(:to_hash)
        raise ArgumentError, "Sensu Enterprise Dashboard OIDC config must be a Hash"
      end
    end
  end

  autorequire(:package) do
    ['sensu-enterprise-dashboard']
  end
end
