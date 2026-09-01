$password = 'sensu'

class { 'sensu':
  use_ssl       => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
  api_host      => 'sensu-backend',
}

class { 'sensu::agent':
  backends    => ['sensu-backend:8081'],
  config_hash => {
    'keepalive-interval' => 5,
  },
}

class { 'postgresql::globals':
  manage_package_repo => false,
  version             => '16',
}

# Ensure data directory is ready for initdb
exec { 'clean_postgres_datadir_if_incomplete':
  command => '/bin/rm -rf /var/lib/pgsql/data/*',
  onlyif  => '/bin/bash -c "[ -d /var/lib/pgsql/data ] && [ ! -f /var/lib/pgsql/data/PG_VERSION ]"',
  require => Class['postgresql::server::install'],
  before  => Class['postgresql::server::initdb'],
}

class { 'postgresql::server':
  listen_addresses => '*',
}

# Copy SSL key for PostgreSQL — must exist after initdb but before service starts
file { 'postgresql_ssl_key_file':
  ensure  => 'file',
  path    => "${postgresql::server::datadir}/server.key",
  source  => '/etc/puppetlabs/puppet/ssl/private_keys/sensu-agent.pem',
  owner   => 'postgres',
  group   => 'postgres',
  mode    => '0600',
  require => Class['postgresql::server::initdb'],
  before  => Class['postgresql::server::service'],
}

postgresql::server::config_entry { 'ssl':
  value => 'on',
}

postgresql::server::config_entry { 'ssl_cert_file':
  value => '/etc/puppetlabs/puppet/ssl/ca/signed/sensu-agent.pem',
}

postgresql::server::config_entry { 'ssl_key_file':
  value   => 'server.key',
  require => File['postgresql_ssl_key_file'],
}

postgresql::server::config_entry { 'ssl_ca_file':
  value => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
}

postgresql::server::db { 'sensu':
  user     => 'sensu',
  password => postgresql::postgresql_password('sensu', $password),
}

postgresql::server::pg_hba_rule { 'allow access to sensu database':
  description => 'Open up postgresql for access to sensu from 0.0.0.0/0',
  type        => 'host',
  database    => 'sensu',
  user        => 'sensu',
  address     => '0.0.0.0/0',
  auth_method => 'password',
}
