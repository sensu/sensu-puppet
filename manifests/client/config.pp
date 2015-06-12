# = Class: sensu::client::config
#
# Sets the Sensu client config
#
class sensu::client::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::purge_config and !$sensu::client {
    $ensure = 'absent'
  } else {
    $ensure = 'present'
  }

  file { '/etc/sensu/conf.d/client.json':
    ensure => $ensure,
    owner  => 'sensu',
    group  => 'sensu',
    mode   => '0440',
  }

  sensu_client_config { $::fqdn:
    ensure        => $ensure,
    client_name   => $sensu::client_name,
    address       => $sensu::client_address,
    bind          => $sensu::client_bind,
    port          => $sensu::client_port,
    subscriptions => union($sensu::subscriptions, hiera_array('sensu::subscriptions', '')),
    safe_mode     => $sensu::safe_mode,
    custom        => $sensu::client_custom, # merge($sensu::client_custom, hiera_hash('sensu::client_custom', '')),
    keepalive     => $sensu::client_keepalive,
  }

}
