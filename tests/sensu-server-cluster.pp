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
    rabbitmq_cluster => [
      {
        'port'            => '1234',
        'host'            => 'sensu-server.example.com',
        'user'            => 'sensuuser',
        'password'        => 'sensupass',
        'vhost'           => '/myvhost',
        'ssl_cert_chain'  => '/etc/sensu/ssl/cert.pem',
        'ssl_private_key' => '/etc/sensu/ssl/key.pem'
      },
      {
        'port'            => '1234',
        'host'            => 'sensu-server.example.com',
        'user'            => 'sensuuser',
        'password'        => 'sensupass',
        'vhost'           => '/myvhost',
        'ssl_cert_chain'  => '/etc/sensu/ssl/cert.pem',
        'ssl_private_key' => '/etc/sensu/ssl/key.pem'
      }
    ]
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
