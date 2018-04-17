class { '::sensu::agent':
  config_hash => {
    'backend-url' => ['ws://192.168.52.10:8081']
  },
}
