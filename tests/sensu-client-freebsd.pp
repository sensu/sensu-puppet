# Note: Check http://repositories.sensuapp.org/msi/ for the latest version.
class { '::sensu':
  version           => '0.29.0-11',
  rabbitmq_password => 'correct-horse-battery-staple',
  rabbitmq_host     => '192.168.56.10',
  rabbitmq_vhost    => '/sensu',
  subscriptions     => 'all',
  client_address    => $::ipaddress_vtnet1,
  pkg_url           => 'https://sensu.global.ssl.fastly.net/freebsd/FreeBSD:10:amd64/sensu/sensu-0.29.0_11.txz',
}
