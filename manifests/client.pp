# = Class: sensu::client
#
# Configures Sensu clients
#
# == Parameters
#
class sensu::client(
  $address        = $::ipaddress,
  $subscriptions  = [],
  $client_name    = $::fqdn,
  $enabled        = 'true',
  $purge_config   = 'false',
  $safe_mode      = false,
) {

  $ensure = $enabled ? {
    'true'  => 'present',
    true    => 'present',
    default => 'absent'
  }

  if $purge_config {
    file { '/etc/sensu/conf.d/client.json': ensure => $ensure }
  }

  sensu_client_config { $::fqdn:
    ensure        => $ensure,
    client_name   => $client_name,
    address       => $address,
    subscriptions => $subscriptions,
    safe_mode     => $safe_mode,
  }

}
