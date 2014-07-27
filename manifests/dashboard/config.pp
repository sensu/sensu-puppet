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

  if is_bool($sensu::dashboard) and $sensu::dashboard {
    file { $sensu::dashboard_config_file :
      ensure  => $ensure,
      owner   => 'sensu',
      group   => 'sensu',
      mode    => '0440',
    }
    sensu_dashboard_config { $::fqdn:
      ensure    => $ensure,
      bind      => $sensu::dashboard_bind,
      host      => $sensu::dashboard_host,
      port      => $sensu::dashboard_port,
      user      => $sensu::dashboard_user,
      password  => $sensu::dashboard_password,
      notify    => Class['sensu::dashboard::service'],
    }
  } elsif !is_bool($sensu::dashboard) and $sensu::dashboard {
    file { $sensu::dashboard_config_file :
      ensure  => $ensure,
      owner   => 'sensu',
      group   => 'sensu',
      mode    => '0644',
      content => template("sensu/dashboard/${sensu::dashboard}.erb"),
    }
  }

}
