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
  $dsn = "postgresql://${user}:${password}@${host}:${port}/${dbname}"

  sensu_postgres_config { $sensu::backend::postgresql_name:
    ensure    => $sensu::backend::datastore_ensure,
    dsn       => Sensitive($dsn),
    pool_size => $sensu::backend::postgresql_pool_size,
  }

  if $sensu::backend::manage_postgresql_db and $sensu::backend::datastore_ensure == 'present' {
    postgresql::server::db { $dbname:
      user     => $user,
      password => postgresql_password($user, $password),
      before   => Sensu_postgres_config[$sensu::backend::postgresql_name],
    }
  }
}
