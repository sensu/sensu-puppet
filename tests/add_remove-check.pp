node 'sensu-server' {

  class { '::sensu':
    install_repo          => true,
    server                => true,
    manage_services       => true,
    manage_user           => true,
    rabbitmq_password     => 'correct-horse-battery-staple',
    rabbitmq_vhost        => '/sensu',
    spawn_limit           => 16,
    api                   => true,
    api_user              => 'admin',
    api_password          => 'secret',
    client_address        => $::ipaddress_eth1,
    subscriptions         => ['all', 'roundrobin:poller'],
    client_deregister     => true,
    client_deregistration => {'handler' => 'deregister_client'},
  }

  if $::test == 'add' {
    sensu::check { 'check_to_remove':
      command     => 'PATH=$PATH:/usr/lib64/nagios/plugins check_ntp_time -H :::address::: -w 30 -c 60',
      standalone  => false,
      handlers    => 'default',
      subscribers => 'roundrobin:poller',
      cron        => '*/5 * * * *',
    }
  } else {
    sensu::check { 'check_to_remove':
      ensure => 'absent',
    }
  }
}
