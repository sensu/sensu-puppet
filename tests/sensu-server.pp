node 'sensu-server' {
  $deregistration = { 'handler' => 'deregister_client' }

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
    client_deregistration => $deregistration,
  }

  sensu::handler { 'default':
    command => 'mail -s \'sensu alert\' ops@example.com',
  }

  sensu::check { 'check_ntp':
    command     => 'PATH=$PATH:/usr/lib64/nagios/plugins check_ntp_time -H pool.ntp.org -w 30 -c 60',
    handlers    => 'default',
    subscribers => 'sensu-test',
  }

  $proxy_requests_ntp = {
    'client_attributes' => {
      'subscriptions' => 'eval: value.include?("ntp")',
    },
  }

  # Example check using the cron schedule.
  sensu::check { 'remote_check_ntp':
    command        => 'PATH=$PATH:/usr/lib64/nagios/plugins check_ntp_time -H :::address::: -w 30 -c 60',
    standalone     => false,
    handlers       => 'default',
    subscribers    => 'roundrobin:poller',
    cron           => '*/5 * * * *',
    proxy_requests => $proxy_requests_ntp,
  }

  # A client defined in the Dashboard with a subscription of "http" will
  # automatically have this check associated with it.  Check Google with the
  # following API call to create a proxy client definition:
  #
  #     curl -s -i -X POST -H 'Content-Type: application/json' \
  #       -d '{"name":"google.com","address":"google.com","subscriptions":["http"]}' \
  #       http://admin:secret@127.0.0.1:4567/clients
  #
  # Then, trigger the check with:
  #
  #     curl -s -i -X POST -H 'Content-Type: application/json' \
  #       -d '{"check": "remote_http"}' \
  #       http://admin:secret@127.0.0.1:4567/request
  $proxy_requests_http = {
    'client_attributes' => {
      'subscriptions' => 'eval: value.include?("http")',
    },
  }
  sensu::check { 'remote_http':
    command             => '/opt/sensu/embedded/bin/check-http.rb -u http://:::address:::',
    occurrences         => 2,
    interval            => 300,
    refresh             => 600,
    low_flap_threshold  => 20,
    high_flap_threshold => 60,
    standalone          => false,
    subscribers         => 'roundrobin:poller',
    proxy_requests      => $proxy_requests_http,
  }
}
