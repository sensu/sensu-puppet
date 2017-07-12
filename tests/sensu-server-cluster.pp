# This provisioning manifest configures sensu-server as if it were connected to
# a rabbitmq cluster.  It doesn't actually configure multiple running rabbitmq
# instances, it configures just one.  The purpose is to exercise the sensu
# cluster configuration, e.g. to exercise the expected behavior reported
# in https://github.com/sensu/sensu-puppet/issues/598
#
# NOTE: rabbitmq_password should be ignored with rabbitmq_cluster specified.
node 'sensu-server' {
  class { '::sensu':
    install_repo      => true,
    server            => true,
    manage_services   => true,
    manage_user       => true,
    api               => true,
    api_user          => 'admin',
    api_password      => 'secret',
    client_address    => $::ipaddress_eth1,
    rabbitmq_password => 'correct-horse-battery-staple',
    rabbitmq_cluster  => [
      {
        'port'      => '5671',
        'host'      => 'sensu-server.example.com',
        'user'      => 'sensu',
        'password'  => 'correct-horse-battery-staple',
        'vhost'     => '/sensu',
        'prefetch'  => 50,
        'heartbeat' => 30,
      },
      {
        'port'      => '5672',
        'host'      => 'sensu-server.example.com',
        'user'      => 'sensu',
        'password'  => 'correct-horse-battery-staple',
        'vhost'     => '/sensu',
        'prefetch'  => 50,
        'heartbeat' => 30,
      },
      {
        'port'      => '5673',
        'host'      => 'sensu-server.example.com',
        'user'      => 'sensu',
        'password'  => 'correct-horse-battery-staple',
        'vhost'     => '/sensu',
        'prefetch'  => 50,
        'heartbeat' => 30,
      },
    ],
  }

  sensu::handler { 'default':
    command => 'mail -s \'sensu alert\' ops@example.com',
  }

  sensu::check { 'check_ntp':
    command     => 'PATH=$PATH:/usr/lib/nagios/plugins check_ntp_time -H pool.ntp.org -w 30 -c 60',
    handlers    => 'default',
    subscribers => 'sensu-test',
  }
}
