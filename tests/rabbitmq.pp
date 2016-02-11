# Create entries in /etc/hosts
host { 'sensu-client.example.com':
  ensure       => present,
  ip           => '192.168.56.11',
  host_aliases => 'sensu-client',
}
host { 'sensu-server.example.com':
  ensure       => present,
  ip           => '192.168.56.10',
  host_aliases => 'sensu-server',
}
class {'::rabbitmq':
  # By default, rabbitmq creates a user guest:guest, however they can only authenticate from localhost
  # Delete the guest user since a sensu user will be created. Create rabbitmq cluster. 
  delete_guest_user        => true,
  config_cluster           => true,
  default_user             => 'sensu',
  default_pass             => 'correct-horse-battery-staple',
  cluster_nodes            => ['sensu-server', 'sensu-client'],
  erlang_cookie            => 'correct-horse-battery-staple',
  wipe_db_on_cookie_change => true,
}
