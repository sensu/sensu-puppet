$password = 'sensu'

class { 'sensu':
  use_ssl       => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
  api_host      => 'sensu-backend',
}

include sensu::cli

class { 'sensu::agent':
  backends => ['sensu-backend:8081'],
}

class { 'sensu::backend':
  ssl_cert_source      => '/etc/puppetlabs/puppet/ssl/ca/signed/sensu-backend.pem',
  ssl_key_source       => '/etc/puppetlabs/puppet/ssl/private_keys/sensu-backend.pem',
  datastore            => 'postgresql',
  manage_postgresql_db => false,
  postgresql_host      => 'sensu-agent',
  postgresql_password  => $password,
}
