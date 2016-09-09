# = Class: sensu::redis::config
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

  # redis configuration may contain "secrets"
  file { "${sensu::etc_dir}/conf.d/redis.json":
    ensure => $ensure,
    owner  => $sensu::user,
    group  => $sensu::group,
    mode   => $sensu::file_mode,
    before => Sensu_redis_config[$::fqdn],
  }

  $has_sentinels = !($sensu::redis_sentinels == undef or $sensu::redis_sentinels == [])
  $host = $has_sentinels ? { false => $sensu::redis_host, true  => undef, }
  $port = $has_sentinels ? { false => $sensu::redis_port, true  => undef, }
  $sentinels = $has_sentinels ? { true  => $sensu::redis_sentinels, false => undef, }
  $master = $has_sentinels ? { true => $sensu::redis_master, false => undef, }

  sensu_redis_config { $::fqdn:
    ensure             => $ensure,
    base_path          => "${sensu::etc_dir}/conf.d",
    host               => $host,
    port               => $port,
    password           => $sensu::redis_password,
    reconnect_on_error => $sensu::redis_reconnect_on_error,
    db                 => $sensu::redis_db,
    auto_reconnect     => $sensu::redis_auto_reconnect,
    sentinels          => $sentinels,
    master             => $master,
  }

}
