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
  $enabled        = 'true'
) {

  $ensure = $enabled ? {
    'true'  => 'present',
    true    => 'present',
    default => 'absent'
  }

  sensu_client_config { $::fqdn:
    ensure        => $ensure,
    client_name   => $client_name,
    address       => $address,
    subscriptions => $subscriptions,
  }

}
