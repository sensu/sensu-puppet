$password = 'sensu'
$master_ip = '192.168.52.11'

include sensu
class { 'sensu::agent':
  backends => ['sensu-backend:8081'],
}
class { 'sensu::backend':
  datastore            => 'postgresql',
  manage_postgresql_db => false,
  postgresql_host      => $master_ip,
  postgresql_password  => $password,
}

# Use Puppet certs when connecting to Sensu DB's Postgresql service
file { '/var/lib/sensu/.postgresql':
  ensure  => 'directory',
  owner   => 'sensu',
  group   => 'sensu',
  mode    => '0755',
  require => Package['sensu-go-backend'],
  notify  => Service['sensu-backend'],
}

file { '/var/lib/sensu/.postgresql/root.crl':
  ensure => 'file',
  source => '/etc/puppetlabs/puppet/ssl/crl.pem',
  owner  => 'sensu',
  group  => 'sensu',
  mode   => '0644',
  notify => Service['sensu-backend'],
}

file { '/var/lib/sensu/.postgresql/root.crt':
  ensure => 'file',
  source => $sensu::ssl_ca_source,
  owner  => 'sensu',
  group  => 'sensu',
  mode   => '0644',
  notify => Service['sensu-backend'],
}

file { '/var/lib/sensu/.postgresql/postgresql.crt':
  ensure => 'file',
  source => $sensu::backend::ssl_cert_source,
  owner  => 'sensu',
  group  => 'sensu',
  mode   => '0644',
  notify => Service['sensu-backend'],
}

file { '/var/lib/sensu/.postgresql/postgresql.key':
  ensure => 'file',
  source => $sensu::backend::ssl_key_source,
  owner  => 'sensu',
  group  => 'sensu',
  mode   => '0600',
  notify => Service['sensu-backend'],
}
