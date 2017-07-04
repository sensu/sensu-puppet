node 'sensu-server' {

  file { 'api.keystore':
    ensure => 'file',
    path   => '/etc/sensu/api.keystore',
    source => 'puppet:///modules/sensu/test.api.keystore',
    owner  => 'sensu',
    group  => 'sensu',
    mode   => '0600',
  }

  class { '::sensu':
    install_repo              => true,
    server                    => true,
    manage_services           => true,
    manage_user               => true,
    rabbitmq_password         => 'correct-horse-battery-staple',
    rabbitmq_vhost            => '/sensu',
    api                       => true,
    api_user                  => 'admin',
    api_password              => 'secret',
    client_address            => $::ipaddress_eth1,
    # enterprise options
    api_ssl_port              => '4568',
    api_ssl_keystore_file     => '/etc/sensu/api.keystore',
    api_ssl_keystore_password => 'sensutest',
  }

  sensu::handler { 'default':
    command => 'mail -s \'sensu alert\' ops@example.com',
  }

  sensu::check { 'check_ntp':
    command     => 'PATH=$PATH:/usr/lib64/nagios/plugins check_ntp_time -H pool.ntp.org -w 30 -c 60',
    handlers    => 'default',
    subscribers => 'sensu-test',
  }
}
