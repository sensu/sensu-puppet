# = Class: sensu::dashboard::config
#
# Sets the Sensu dashboard config
#
class sensu::dashboard::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::purge_config and !$sensu::dashboard {
    $ensure = 'absent'
  } else {
    $ensure = 'present'
  }

  file { '/etc/sensu/conf.d/dashboard.json':
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0440',
  }

  sensu_dashboard_config { $::fqdn:
    ensure    => $ensure,
    host      => $sensu::dashboard_host,
    port      => $sensu::dashboard_port,
    user      => $sensu::dashboard_user,
    password  => $sensu::dashboard_password,
    notify    => Class['sensu::dashboard::service'],

  }

}
