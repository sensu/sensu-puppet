# Note: Check http://repositories.sensuapp.org/msi/ for the latest version.
class { '::sensu':
  version           => '0.29.0-11',
  rabbitmq_password => 'correct-horse-battery-staple',
  rabbitmq_host     => '192.168.56.10',
  rabbitmq_vhost    => '/sensu',
  subscriptions     => 'all',
  client_address    => $facts['networking']['ip'],
}

# Test for #820
::sensu::subscription { 'roundrobin:foo':
  ensure => present,
}

# Test for #870
::sensu::handler { 'operations':
  type       => 'pipe',
  command    => '/opt/sensu/embedded/bin/handler-pagerduty.rb',
  severities => ['critical'],
}
