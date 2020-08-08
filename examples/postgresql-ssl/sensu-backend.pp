$password = 'sensu'

include sensu
class { 'sensu::agent':
  backends => ['sensu-backend:8081'],
}
class { 'sensu::backend':
  datastore                  => 'postgresql',
  manage_postgresql_db       => false,
  postgresql_host            => 'sensu-agent',
  postgresql_password        => $password,
  postgresql_ssl_ca_source   => $sensu::ssl_ca_source,
  postgresql_ssl_crl_source  => $facts['puppet_hostcrl'],
  postgresql_ssl_cert_source => $facts['puppet_hostcert'],
  postgresql_ssl_key_source  => $facts['puppet_hostprivkey'],
}
