# = Class: sensu::client::config
#
# Sets the Sensu client config
#
class sensu::client::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::_purge_config and !$sensu::client {
    $ensure = 'absent'
  } else {
    $ensure = 'present'
  }

  file { "${sensu::conf_dir}/client.json":
    ensure => $ensure,
    owner  => $sensu::user,
    group  => $sensu::group,
    mode   => $sensu::file_mode,
  }

  sensu_client_config { $::fqdn:
    ensure        => $ensure,
    base_path     => $sensu::conf_dir,
    client_name   => $sensu::client_name,
    address       => $sensu::client_address,
    socket        => {
                        bind => $sensu::client_bind,
                        port => $sensu::client_port,
                      },
    subscriptions => $sensu::subscriptions,
    safe_mode     => $sensu::safe_mode,
    custom        => $sensu::client_custom,
    keepalive     => $sensu::client_keepalive,
    redact        => $sensu::redact,
  }

}
