# = Class: sensu::server
#
# Builds Sensu servers
#
# == Parameters
#

class sensu::server(
  $redis_host         = 'localhost',
  $redis_port         = '6379',
  $api_host           = 'localhost',
  $api_port           = '4567',
  $dashboard_host     = $::ipaddress,
  $dashboard_port     = '8080',
  $dashboard_user     = 'admin',
  $dashboard_password = 'secret',
  $enabled            = 'false',
  $purge_config       = 'false',
) {

  $ensure = $enabled ? {
    'true'  => 'present',
    true    => 'present',
    default => 'absent'
  }

  file { '/etc/sensu/conf.d/redis.json':
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0444',
  }

  file { '/etc/sensu/conf.d/api.json':
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0444',
  }

  file { '/etc/sensu/conf.d/dashboard.json':
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0440',
  }

  file { ['/etc/sensu/conf.d/checks', '/etc/sensu/conf.d/handlers']:
    ensure  => directory,
    mode    => '0555',
    owner   => 'sensu',
    group   => 'sensu',
    purge   => $purge_config,
    recurse => true,
    require => Package['sensu'],
  }

  sensu_redis_config { $::fqdn:
    ensure => $ensure,
    host   => $redis_host,
    port   => $redis_port,
  }

  sensu_api_config { $::fqdn:
    ensure => $ensure,
    host   => $api_host,
    port   => $api_port,
  }

  sensu_dashboard_config { $::fqdn:
    ensure   => $ensure,
    host     => $dashboard_host,
    port     => $dashboard_port,
    user     => $dashboard_user,
    password => $dashboard_password,
  }
}
