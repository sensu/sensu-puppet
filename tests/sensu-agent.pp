class { 'sensu':
  api_host => 'sensu-backend.example.com',
}
class { 'sensu::agent':
  backends => ['sensu-backend.example.com:8081'],
}
