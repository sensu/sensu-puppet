# = Class: sensu::redis::config
#
# Sets the Sensu redis config
#
class sensu::redis::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::purge_config_real and !$sensu::server_real and !$sensu::api_real and !$sensu::dashboard_real {
    $ensure = 'absent'
  } else {
    $ensure = 'present'
  }

  file { '/etc/sensu/conf.d/redis.json':
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0444',
  }

  sensu_redis_config { $::fqdn:
    ensure  => $ensure,
    host    => $sensu::redis_host,
    port    => $sensu::redis_port,
  }

}
