$password = 'sensu'

class { 'sensu::agent':
  backends => ['sensu-backend:8081'],
}

class { 'postgresql::globals':
  manage_package_repo => true,
  version             => '9.6',
}

class { 'postgresql::server':
  listen_addresses => '*',
}

file { 'postgresql_ssl_key_file':
  ensure => 'file',
  path   => "${postgresql::server::datadir}/${trusted['certname']}.pem",
  source => "/etc/puppetlabs/puppet/ssl/private_keys/${trusted['certname']}.pem",
  owner  => 'postgres',
  group  => 'postgres',
  mode   => '0600',
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

postgresql::server::config_entry { 'ssl':
  value => 'on',
}

postgresql::server::config_entry { 'ssl_cert_file':
  value => "/etc/puppetlabs/puppet/ssl/certs/${trusted['certname']}.pem",
}

postgresql::server::config_entry { 'ssl_key_file':
  value   => "${trusted['certname']}.pem",
  require => File['postgresql_ssl_key_file'],
}

postgresql::server::config_entry { 'ssl_ca_file':
  value => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
}

postgresql::server::config_entry { 'ssl_crl_file':
  value => '/etc/puppetlabs/puppet/ssl/crl.pem',
}
