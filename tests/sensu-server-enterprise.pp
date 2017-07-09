node 'sensu-server' {

  file { 'api.keystore':
    ensure => 'file',
    path   => '/etc/sensu/api.keystore',
    source => 'puppet:///modules/sensu/test.api.keystore',
    owner  => 'sensu',
    group  => 'sensu',
    mode   => '0600',
  }

  # NOTE: When testing sensu enterprise, provide the SE_USER and SE_PASS to use
  # with the online repository using the FACTER_SE_USER and FACTER_SE_PASS
  # environment variables.  An effective way to manage this is with `direnv`
  class { '::sensu':
    install_repo              => true,
    enterprise                => true,
    enterprise_user           => $facts['se_user'],
    enterprise_pass           => $facts['se_pass'],
    manage_services           => true,
    manage_user               => true,
    rabbitmq_password         => 'correct-horse-battery-staple',
    rabbitmq_vhost            => '/sensu',
    client_address            => $::ipaddress_eth1,
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

  # Exercise [Contact Routing](https://github.com/sensu/sensu-puppet/issues/597)
  # This overrides the built-in email and slack handlers.
  sensu::contact { 'support':
    ensure => 'present',
    config => {
      'email' => {
        'to'   => 'support@example.com',
        'from' => 'sensu.noreply@example.com',
      },
      'slack' => {
        'channel' => '#support',
      },
    },
  }
  sensu::contact { 'ops':
    ensure => 'present',
    config => { 'email'  => { 'to' => 'ops@example.com' } },
  }
  sensu::contact { 'departed':
    ensure => 'absent',
  }
  # A second check to use the built-in email handler and contact.
  sensu::check { 'check_ntp_with_routing':
    command     => 'PATH=$PATH:/usr/lib64/nagios/plugins check_ntp_time -H pool.ntp.org -w 30 -c 60',
    handlers    => 'email',
    contacts    => ['ops', 'support'],
    subscribers => 'sensu-test',
  }
}
