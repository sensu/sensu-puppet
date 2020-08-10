$password = 'sensu'
$repl_password = 'secret'
$pgpassword = 'password'
$primary_ip = '192.168.52.11'
$standby_ip = '192.168.52.10'

if $facts['networking']['ip'] == $primary_ip {
  $primary = true
  $primary_ensure = 'present'
} else {
  $primary = false
  $primary_ensure = 'absent'
}

class { 'postgresql::globals':
  manage_package_repo => true,
  version             => '9.6',
}
class { 'postgresql::server':
  listen_addresses     => '*',
  postgres_password    => $pgpassword,
  manage_recovery_conf => true,
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
  value => "${trusted['certname']}.pem",
}

postgresql::server::config_entry { 'ssl_ca_file':
  value => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
}

postgresql::server::config_entry { 'ssl_crl_file':
  value => '/etc/puppetlabs/puppet/ssl/crl.pem',
}

file { 'postgresql_ssl_key_file':
  ensure => 'file',
  path   => "${postgresql::server::datadir}/${trusted['certname']}.pem",
  source => "/etc/puppetlabs/puppet/ssl/private_keys/${trusted['certname']}.pem",
  owner  => 'postgres',
  group  => 'postgres',
  mode   => '0600',
}

# REFERENCE: https://wiki.postgresql.org/wiki/Streaming_Replication
# To enable read-only queries on a standby server, wal_level must be set to
# "hot_standby". But you can choose "archive" if you never connect to the
# server in standby mode.
postgresql::server::config_entry { 'wal_level':
  ensure => $primary_ensure,
  value  => 'hot_standby',
}

# Set the maximum number of concurrent connections from the standby servers.
postgresql::server::config_entry { 'max_wal_senders':
  ensure => $primary_ensure,
  value  => '5',
}

# To prevent the primary server from removing the WAL segments required for
# the standby server before shipping them, set the minimum number of segments
# retained in the pg_xlog directory. At least wal_keep_segments should be
# larger than the number of segments generated between the beginning of
# online-backup and the startup of streaming replication. If you enable WAL
# archiving to an archive directory accessible from the standby, this may
# not be necessary.
postgresql::server::config_entry { 'wal_keep_segments':
  ensure => $primary_ensure,
  value  => '32',
}

if $primary {
  postgresql::server::role { 'repl':
    password_hash => postgresql_password('repl', $repl_password),
    replication   => true,
    require       => Class['postgresql::server::service'],
  }

  postgresql::server::pg_hba_rule { 'allow access to repl for replication':
    description => "Allow replication for repl from ${standby_ip}/32",
    type        => 'host',
    database    => 'replication',
    user        => 'repl',
    address     => "${standby_ip}/32",
    auth_method => 'md5',
  }
} else {
  # Enable read-only queries, modify/remove if primary wal_level is archive
  postgresql::server::config_entry { 'hot_standby':
    value => 'on',
  }

  postgresql::server::recovery { 'repl':
    standby_mode     => 'on',
    primary_conninfo => "host=${primary_ip} port=5432 user=repl password=${repl_password} sslmode=prefer sslcompression=1",
  }
}
