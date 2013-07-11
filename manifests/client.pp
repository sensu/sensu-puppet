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
  $safe_mode      = false,
  $custom         = {}
) {

  $ensure = $enabled ? {
    'true'  => 'present',
    true    => 'present',
    default => 'absent'
  }

  file { '/etc/sensu/conf.d/client.json':
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0444',
  }

  sensu_client_config { $::fqdn:
    ensure        => $ensure,
    client_name   => $client_name,
    address       => $address,
    subscriptions => $subscriptions,
    safe_mode     => $safe_mode,
    custom        => $custom,
  }

}
