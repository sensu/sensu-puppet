# Sensu Go docs: https://docs.sensu.io/sensu-go/latest/installation/auth/#ldap-authentication
#
# The documentation for the puppet types are available at the following links.
# http://sensu.github.io/sensu-puppet/puppet_types/sensu_ldap_auth.html
# http://sensu.github.io/sensu-puppet/puppet_types/sensu_role_binding.html
#
# Access the backend in a web browser at http://sensu-backend.example.com:3000
# and login with your LDAP credentials. If you can login but see a 404, LDAP
# auth is working but role access is not yet granted — modify sensu_role_binding.

# Replace with your LDAP server details
$ldap_server        = 'ldap.example.com'
$ldap_bind_password = 'password'

class { 'sensu':
  use_ssl => false,
}

class { 'sensu::backend':
  # Enable debug logging to diagnose LDAP authentication issues
  config_hash => {
    'log-level' => 'debug',
  },
}

sensu_ldap_auth { 'openldap':
  ensure  => 'present',
  servers => [
    {
      'host'         => $ldap_server,
      'port'         => 389,
      'security'     => 'starttls',
      'binding'      => {
        'user_dn'  => 'cn=sensu,ou=Services,dc=ops,dc=example,dc=com',
        'password' => $ldap_bind_password,
      },
      'group_search' => {
        'base_dn'      => 'dc=ops,dc=example,dc=com',
        'object_class' => 'posixGroup',
        'attribute'    => 'memberUid',
      },
      'user_search'  => {
        'base_dn' => 'dc=ops,dc=example,dc=com',
      },
    },
  ],
}

sensu_role_binding { 'ldap-ops':
  ensure   => 'present',
  role_ref => {
    'type' => 'ClusterRole',
    'name' => 'cluster-admin',
  },
  subjects => [
    {
      'type' => 'Group',
      'name' => 'ops',
    },
  ],
}
