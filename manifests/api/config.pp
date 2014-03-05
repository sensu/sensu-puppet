# = Class: sensu::api::config
#
# Sets the Sensu API config
#
class sensu::api::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::purge_config and !$sensu::server and !$sensu::api and !$sensu::dashboard {
    $ensure = 'absent'
  } else {
    $ensure = 'present'
  }

  file { '/etc/sensu/conf.d/api.json':
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0440',
  }

  sensu_api_config { $::fqdn:
    ensure   => $ensure,
    host     => $sensu::api_host,
    port     => $sensu::api_port,
    user     => $sensu::api_user,
    password => $sensu::api_password,
  }

}
