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

  if $merge_subscriptions {
    $subscriptions = union ( hiera_array('sensu::subscriptions', []), $sensu::subscriptions )
  } else {
    $subscriptions = $sensu::subscriptions
  }

  if $merge_client_custom {
    $client_custom  = merge ( hiera_hash('sensu::client_custom', {}) , $sensu::client_custom )
  } else {
    $client_custom = $sensu::client_custom
  }

  sensu_client_config { $::fqdn:
    ensure        => $ensure,
    client_name   => $sensu::client_name,
    address       => $sensu::client_address,
    bind          => $sensu::client_bind,
    port          => $sensu::client_port,
    subscriptions => $subscriptions,
    safe_mode     => $sensu::safe_mode,
    custom        => $client_custom,
    keepalive     => $sensu::client_keepalive,
  }

}
