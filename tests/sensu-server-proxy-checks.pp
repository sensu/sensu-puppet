# This test manifest is intended to layer on top of the sensu-server Vagrant VM.
# It defines additional checks executed using proxy clients.  To add a remote
# proxy client, use the Uchiwa UI at http://localhost:3000/#/clients and add a
# client like so.  Once added, request a check for `remote_http` and it will
# automatically run against the Google proxy client.
#
# {
#   "address": "www.google.com",
#   "keepalives": false,
#   "name": "google",
#   "subscriptions": [
#     "client:google",
#     "http"
#   ],
#   "type": "proxy"
# }
node 'sensu-server' {
  Package {
    ensure => installed,
  }
  Sensu::Plugin {
    type         => 'package',
    pkg_provider => 'sensu_gem',
    pkg_version  => 'installed',
    require      => [Package['gcc-c++']],
  }

  class { '::sensu':
    install_repo      => true,
    server            => true,
    manage_services   => true,
    manage_user       => true,
    rabbitmq_password => 'correct-horse-battery-staple',
    rabbitmq_vhost    => '/sensu',
    api               => true,
    api_user          => 'admin',
    api_password      => 'secret',
    client_address    => $::ipaddress_eth1,
    subscriptions     => ['all', 'poller', 'proxytarget', 'roundrobin:poller'],
  }

  sensu::handler { 'default':
    command => 'mail -s \'sensu alert\' ops@example.com',
  }

  sensu::check { 'check_ntp':
    command     => 'PATH=$PATH:/usr/lib64/nagios/plugins check_ntp_time -H pool.ntp.org -w 30 -c 60',
    handlers    => 'default',
    subscribers => 'sensu-test',
  }

  # sensu-plugins-http requires a c++ compiler during install
  package { 'gcc-c++': }

  # (#637) Create a [Proxy
  # Check](https://sensuapp.org/docs/latest/reference/checks.html#proxy-requests-attributes)
  # This needs to have a corresponding sensu-client matching the client
  # attributes.
  sensu::plugin { 'sensu-plugins-http': }

  # A client defined in the Dashboard with a subscription of "http" will
  # automatically have this check associated with it.
  sensu::check { 'remote_http':
    command             => '/opt/sensu/embedded/bin/check-http.rb -u http://:::address:::',
    occurrences         => 2,
    interval            => 300,
    refresh             => 600,
    low_flap_threshold  => 20,
    high_flap_threshold => 60,
    standalone          => false,
    subscribers         => 'roundrobin:poller',
    proxy_requests      => {
      'client_attributes' => {
        'subscriptions' => 'eval: value.include?("http")',
      },
    },
  }
  # Similar to above, but not using round robin checks.
  sensu::check { 'remote_http-dashboard':
    command             => '/opt/sensu/embedded/bin/check-http.rb -u http://:::address::::3000',
    occurrences         => 2,
    interval            => 300,
    refresh             => 600,
    low_flap_threshold  => 20,
    high_flap_threshold => 60,
    standalone          => false,
    subscribers         => 'poller',
    proxy_requests      => {
      'client_attributes' => {
        'subscriptions' => 'eval: value.include?("proxytarget")',
      },
    },
  }
}
