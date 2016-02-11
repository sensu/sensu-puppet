class { '::sensu':
  rabbitmq_password      => 'correct-horse-battery-staple',
  rabbitmq_host          => '192.168.56.10',
  rabbitmq_vhost         => '/sensu',
  subscriptions          => ['sensu-test','all'],
  client_keepalive       => { handlers => ['default'] },
  client_address         => $::ipaddress_eth1,
  use_embedded_ruby      => true,
  rabbitmq_cluster       => true,
  rabbitmq_cluster_hosts => ['sensu-client','sensu-server'],
}
package { 'sensu-plugins-cpu-checks':
  ensure   => 'installed',
  provider => 'sensu_gem',
}

