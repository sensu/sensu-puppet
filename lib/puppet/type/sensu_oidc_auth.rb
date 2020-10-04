require_relative '../../puppet_x/sensu/type'
require_relative '../../puppet_x/sensu/array_property'
require_relative '../../puppet_x/sensu/array_of_hashes_property'
require_relative '../../puppet_x/sensu/hash_property'
require_relative '../../puppet_x/sensu/integer_property'

Puppet::Type.newtype(:sensu_oidc_auth) do
  desc <<-DESC
@summary Manages Sensu OIDC auth.
@example Add an Active Directory auth
  sensu_oidc_auth { 'oidc':
    ensure            => 'present',
    additional_scopes => ['email','groups'],
    client_id         => '0oa13ry4ypeDDBpxF357',
    client_secret     => 'DlArQRfND4BKBUyO0mE-TL2PWOVwyGjIO1fdk9gX',
    groups_claim      => 'groups',
    groups_prefix     => 'oidc:',
    redirect_uri      => 'https://sensu-backend.example.com:8080/api/enterprise/authentication/v2/oidc/callback',
    server            => 'https://idp.example.com',
    username_claim    => 'email',
    username_prefix   => 'oidc:'
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
    desc "The name of the AD auth."
    validate do |value|
      unless value =~ PuppetX::Sensu::Type.name_regex
        raise ArgumentError, "sensu_ad_auth name invalid"
      end
    end
  end

  newproperty(:client_id) do
    desc 'The OIDC provider application "Client ID"'
  end

  newproperty(:client_secret) do
    desc 'The OIDC provider application "Client Secret"'

    def change_to_s(currentvalue, newvalue)
      return "changed client_secret"
    end
    def is_to_s(currentvalue)
      return '[old client_secret redacted]'
    end
    def should_to_s(newvalue)
      return '[new client_secret redacted]'
    end
  end

  newproperty(:server) do
    desc 'The location of the OIDC server you wish to authenticate against.'
  end

  newproperty(:redirect_uri) do
    desc 'Redirect URL to provide to the OIDC provider.'
  end

  newproperty(:groups_claim) do
    desc "The claim to use to form the associated RBAC groups."
  end

  newproperty(:groups_prefix) do
    desc 'A prefix to use to form the final RBAC groups if required.'
  end

  newproperty(:username_claim) do
    desc "The claim to use to form the final RBAC user name."
  end

  newproperty(:username_prefix) do
    desc 'A prefix to use to form the final RBAC user name.'
  end

  newproperty(:additional_scopes, :array_matching => :all, :parent => PuppetX::Sensu::ArrayProperty) do
    desc 'Scopes to include in the claims'
  end

  newproperty(:disable_offline_access, :boolean => true) do
    desc "Sets if OIDC provider can include the offline_access scope"
    newvalues(:true, :false)
    defaultto(:false)
  end

  validate do
    required_properties = [
      :client_id,
      :client_secret,
      :server,
    ]
    required_properties.each do |property|
      if self[:ensure] == :present && self[property].nil?
        fail "You must provide a #{property}"
      end
    end
  end
end
