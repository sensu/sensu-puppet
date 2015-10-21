# = Class: sensu::api::config
#
# Sets the Sensu API config
#
class sensu::api::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::_purge_config and !$sensu::server and !$sensu::api and !$sensu::enterprise {
    $ensure = 'absent'
  } else {
    $ensure = 'present'
  }

  file { "${sensu::etc_dir}/conf.d/api.json":
    ensure => $ensure,
    owner  => $sensu::user,
    group  => $sensu::group,
    mode   => $sensu::file_mode,
  }

  sensu_api_config { $::fqdn:
    ensure    => $ensure,
    base_path => "${sensu::etc_dir}/conf.d",
    bind      => $sensu::api_bind,
    host      => $sensu::api_host,
    port      => $sensu::api_port,
    user      => $sensu::api_user,
    password  => $sensu::api_password,
  }

}
