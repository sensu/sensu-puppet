include sensu::backend
class { 'sensu::agent':
  backends => ['sensu-backend.example.com:8081'],
}
