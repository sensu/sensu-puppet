#
# Sets the Sensu redis config
#
class sensu::redis::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::_purge_config and !$sensu::server and !$sensu::api and !$sensu::enterprise {
    $ensure = 'absent'
  } else {
    $ensure = 'present'
  }


  if $sensu::sentinels_enabled == false {
    # redis configuration may contain "secrets"
    file { "${sensu::etc_dir}/conf.d/redis.json":
      ensure => $ensure,
      owner  => $sensu::user,
      group  => $sensu::group,
      mode   => $sensu::file_mode,
      before => Sensu_redis_config[$::fqdn],
    }

    sensu_redis_config { $::fqdn:
      ensure             => $ensure,
      base_path          => "${sensu::etc_dir}/conf.d",
      host               => $sensu::redis_host,
      port               => $sensu::redis_port,
      password           => $sensu::redis_password,
      reconnect_on_error => $sensu::redis_reconnect_on_error,
      db                 => $sensu::redis_db,
      auto_reconnect     => $sensu::redis_auto_reconnect,
    }
  } else {
    # redis configuration may contain "secrets"
    file { "${sensu::etc_dir}/conf.d/redis.json":
      ensure => $ensure,
      owner  => $sensu::user,
      group  => $sensu::group,
      mode   => $sensu::file_mode,
      before => Sensu_redis_sentinel_config[$::fqdn],
    }

    sensu_redis_sentinel_config { $::fqdn:
      ensure    => $ensure,
      password  => $sensu::redis_password,
      sentinels => $sensu::redis_sentinels,
    }
  }
}
