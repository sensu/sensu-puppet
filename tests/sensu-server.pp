node 'sensu-server' {
  include stdlib
  class { '::sensu':
    install_repo            => true,
    server                  => true,
    manage_services         => true,
    manage_user             => true,
    rabbitmq_password       => 'correct-horse-battery-staple',
    rabbitmq_vhost          => '/sensu',
    api                     => true,
    api_user                => 'admin',
    api_password            => 'secret',
    subscriptions           => ['sensu-test','all'],
    client_keepalive        => { handlers => ['default'] },
    client_address          => $::ipaddress_eth1,
    use_embedded_ruby       => true,
    rabbitmq_cluster        => true,
    rabbitmq_cluster_custom => [
      {
      host => 'sensu-server',
      },
      {
      host => 'sensu-client',
      },
    ],
  }
}

package { 'sensu-plugins-cpu-checks':
  ensure   => 'installed',
  provider => 'sensu_gem',
}

sensu::handler { 'default':
  command  => 'mail -s \'sensu alert\' ops@example.com',
}

sensu::check { 'check-cpu':
  command     => 'check-cpu.rb',
  handlers    => 'default',
  subscribers => 'sensu-test',
  standalone  => false,
}
