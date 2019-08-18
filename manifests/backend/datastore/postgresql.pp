#
class sensu::backend::datastore::postgresql {
  include ::sensu
  include ::sensu::backend

  $config_path = "${::sensu::etc_dir}/postgresql.yaml"
  $user = $::sensu::backend::postgresql_user
  $password = $::sensu::backend::postgresql_password
  $host = $::sensu::backend::postgresql_host
  $port = $::sensu::backend::postgresql_port
  $dbname = $::sensu::backend::postgresql_dbname
  $config = {
    'type'        => 'PostgresConfig',
    'api_version' => 'store/v1',
    'metadata'    => { 'name' => $::sensu::backend::postgresql_name },
    'spec'        => {
      'dsn'         => "postgresql://${user}:${password}@${host}:${port}/${dbname}",
      'pool_size'   => $::sensu::backend::postgresql_pool_size,
    },
  }
  $yaml_config = to_yaml($config)

  case $::sensu::backend::datastore_ensure {
    'absent': {
      $sensuctl_command = 'sensuctl delete'
    }
    default: {
      $sensuctl_command = 'sensuctl create'
    }
  }

  file { $config_path:
    ensure    => 'file',
    owner     => $::sensu::user,
    group     => $::sensu::group,
    mode      => '0640',
    show_diff => false,
    content   => "${yaml_config}\n# File managed by Puppet\n# ${::sensu::backend::datastore_ensure}\n",
    require   => Package['sensu-go-backend'],
    notify    => Exec['sensuctl-postgresql'],
  }

  exec { 'sensuctl-postgresql':
    path        => '/usr/bin:/bin:/usr/sbin:/sbin',
    command     => "${sensuctl_command} --file ${config_path}",
    refreshonly => true,
    require     => [
      Sensu_configure['puppet'],
      Sensu_user['admin'],
    ],
  }

  if $::sensu::backend::manage_postgresql_db and $::sensu::backend::datastore_ensure == 'present' {
    postgresql::server::db { $dbname:
      user     => $user,
      password => postgresql_password($user, $password),
      before   => Exec['sensuctl-postgresql'],
    }
  }
}

