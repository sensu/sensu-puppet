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
  file { '/etc/sensu/conf.d/redis.json':
    ensure => $ensure,
    owner  => 'sensu',
    group  => 'sensu',
    mode   => '0440',
    before => Sensu_redis_config[$::fqdn],
  }

  sensu_redis_config { $::fqdn:
    ensure             => $ensure,
    host               => $sensu::redis_host,
    port               => $sensu::redis_port,
    password           => $sensu::redis_password,
    reconnect_on_error => $sensu::redis_reconnect_on_error,
    db                 => $sensu::redis_db,
    auto_reconnect     => $sensu::redis_auto_reconnect,
  }

}
