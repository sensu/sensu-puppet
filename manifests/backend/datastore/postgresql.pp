# @summary Manage Sensu backend PostgreSQL datastore
# @api private
#
class sensu::backend::datastore::postgresql {
  include sensu
  include sensu::backend

  $user = $sensu::backend::postgresql_user
  $password = $sensu::backend::postgresql_password
  $host = $sensu::backend::postgresql_host
  $port = $sensu::backend::postgresql_port
  $dbname = $sensu::backend::postgresql_dbname
  $sslmode = $sensu::backend::postgresql_sslmode
  $dsn = "postgresql://${user}:${password}@${host}:${port}/${dbname}?sslmode=${sslmode}"

  sensu_postgres_config { $sensu::backend::postgresql_name:
    ensure        => $sensu::backend::datastore_ensure,
    dsn           => Sensitive($dsn),
    pool_size     => $sensu::backend::postgresql_pool_size,
    strict        => $sensu::backend::postgresql_strict,
    batch_buffer  => $sensu::backend::postgresql_batch_buffer,
    batch_size    => $sensu::backend::postgresql_batch_size,
    batch_workers => $sensu::backend::postgresql_batch_workers,
  }

  if $sensu::backend::manage_postgresql_db and $sensu::backend::datastore_ensure == 'present' {
    postgresql::server::db { $dbname:
      user     => $user,
      password => postgresql::postgresql_password($user, $password),
      before   => Sensu_postgres_config[$sensu::backend::postgresql_name],
    }
  }

  $ssl_dir = $sensu::backend::postgresql_ssl_dir
  $ssl_ca_source = $sensu::backend::postgresql_ssl_ca_source
  $ssl_ca_content = $sensu::backend::postgresql_ssl_ca_content
  $ssl_crl_source = $sensu::backend::postgresql_ssl_crl_source
  $ssl_crl_content = $sensu::backend::postgresql_ssl_crl_content
  $ssl_cert_source = $sensu::backend::postgresql_ssl_cert_source
  $ssl_cert_content = $sensu::backend::postgresql_ssl_cert_content
  $ssl_key_source = $sensu::backend::postgresql_ssl_key_source
  $ssl_key_content = $sensu::backend::postgresql_ssl_key_content

  file { 'sensu-backend postgresql_ssl_dir':
    ensure  => 'directory',
    path    => $ssl_dir,
    owner   => $sensu::sensu_user,
    group   => $sensu::sensu_group,
    mode    => '0755',
    require => Package['sensu-go-backend'],
    notify  => Service['sensu-backend'],
  }
  if $ssl_ca_source or $ssl_ca_content {
    file { 'sensu-backend postgresql_ca':
      ensure  => 'file',
      path    => "${ssl_dir}/root.crt",
      source  => $ssl_ca_source,
      content => $ssl_ca_content,
      owner   => $sensu::sensu_user,
      group   => $sensu::sensu_group,
      mode    => '0644',
      notify  => Service['sensu-backend'],
    }
  }
  if $ssl_crl_source or $ssl_crl_content {
    file { 'sensu-backend postgresql_crl':
      ensure  => 'file',
      path    => "${ssl_dir}/root.crl",
      source  => $ssl_crl_source,
      content => $ssl_crl_content,
      owner   => $sensu::sensu_user,
      group   => $sensu::sensu_group,
      mode    => '0644',
      notify  => Service['sensu-backend'],
    }
  }
  if $ssl_cert_source or $ssl_cert_content {
    file { 'sensu-backend postgresql_cert':
      ensure  => 'file',
      path    => "${ssl_dir}/postgresql.crt",
      source  => $ssl_cert_source,
      content => $ssl_cert_content,
      owner   => $sensu::sensu_user,
      group   => $sensu::sensu_group,
      mode    => '0644',
      notify  => Service['sensu-backend'],
    }
  }
  if $ssl_key_source or $ssl_key_content {
    file { 'sensu-backend postgresql_key':
      ensure  => 'file',
      path    => "${ssl_dir}/postgresql.key",
      source  => $ssl_key_source,
      content => $ssl_key_content,
      owner   => $sensu::sensu_user,
      group   => $sensu::sensu_group,
      mode    => '0600',
      notify  => Service['sensu-backend'],
    }
  }
}
