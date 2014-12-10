# = Class: sensu::flapjack::config
#
# Sets the Sensu flapjack config
#
class sensu::flapjack::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::purge_config and !$sensu::server and !$sensu::api {
    $ensure = 'absent'
  } else {
    $ensure = 'present'
  }

  file { '/etc/sensu/conf.d/flapjack.json':
    ensure => $ensure,
    owner  => 'sensu',
    group  => 'sensu',
    mode   => '0444',
  }

  sensu_flapjack_config { $::fqdn:
    ensure => $ensure,
    host   => $sensu::flapjack_redis_host,
    port   => $sensu::flapjack_redis_port,
    db     => $sensu::flapjack_redis_db,
  }

}
