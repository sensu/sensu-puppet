class sensu::enterprise::dashboard::config {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::purge and !$sensu::enterprise_dashboard {
    if is_hash($sensu::purge) and $::sensu::purge['config'] {
      $ensure = 'absent'
    } else {
      $ensure = 'present'
    }
  } else {
    $ensure = 'present'
  }

  if $ensure == 'present' {
    $_ensure = 'file'
  } else {
    $_ensure = $ensure
  }

  file { '/etc/sensu/dashboard.json':
    ensure => $_ensure,
    owner  => 'sensu',
    group  => 'sensu',
    mode   => '0440',
  }

  sensu_enterprise_dashboard_config { $::fqdn:
    ensure    => $ensure,
    base_path => $::sensu::enterprise_dashboard_base_path,
    host      => $::sensu::enterprise_dashboard_host,
    port      => $::sensu::enterprise_dashboard_port,
    refresh   => $::sensu::enterprise_dashboard_refresh,
    user      => $::sensu::enterprise_dashboard_user,
    pass      => $::sensu::enterprise_dashboard_pass,
    github    => $::sensu::enterprise_dashboard_github,
    ldap      => $::sensu::enterprise_dashboard_ldap,
  }
}
