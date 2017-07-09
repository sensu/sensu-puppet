node default {

  $filters = {
    'offhours'          => {
      'attributes'      => {
        'client'        => {
          'environment' => 'production',
        },
      },
      'when'    => {
        'days'  => {
          'all' => [
            {
              'begin' => '2:00 AM',
              'end'   => '1:00 AM',
            },
          ],
        },
      },
    },
  }

  $filter_defaults = {
    'when'    => {
      'days'  => {
        'all' => [
          {
            'begin' => '2:00 AM',
            'end'   => '1:00 AM',
          },
        ],
      },
    },
  }

  # Use the internal 192.168.56.* address
  if $::ipaddress_vtnet1 { # FreeBSD
    $ip = $::ipaddress_vtnet1
  } elsif $facts['networking']['interfaces']['eth1'] != undef { # EL
    $ip = $facts['networking']['interfaces']['eth1']['ip']
  } elsif $facts['networking']['interfaces']['enp0s8'] != undef { # Ubuntu 16.04
    $ip = $facts['networking']['interfaces']['enp0s8']['ip']
  } else {
    $ip = $facts['networking']['ip']
  }

  class { '::sensu':
    rabbitmq_password => 'correct-horse-battery-staple',
    rabbitmq_host     => '192.168.56.10',
    rabbitmq_vhost    => '/sensu',
    subscriptions     => 'all',
    client_address    => $ip,
    filters           => $filters,
    filter_defaults   => $filter_defaults,
  }
}
