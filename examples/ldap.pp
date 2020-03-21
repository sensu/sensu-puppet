# Read more at Sensu's documentation site.
#
# https://docs.sensu.io/sensu-go/latest/installation/auth/#ldap-authentication
#
# The documentation for the puppet types are available at the following links.
#
# http://sensu.github.io/sensu-puppet/puppet_types/sensu_ldap_auth.html
# http://sensu.github.io/sensu-puppet/puppet_types/sensu_role_binding.html
#
# Access the backend in a web browser such as
# https:://sensu-backend.example.com:3000 and you should be able to login with
# LDAP credentials. If you can login, but see a 404 that means that
# sensu_ldap_auth is likely working but the access for your user is not granted
# and you should modify the sensu_role_binding.
#
class { 'sensu::backend':
  # This will turn on debugging which will make it possible to see the LDAP
  # related Sensu logs.
  config_hash => {
    'debug'     => true,
    'log-level' => 'debug',
  },
}

$ldap_server = 'ldap.example.com'
$ldap_bind_password = 'password'

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
