class { 'sensu::backend':
  ssl_cert_source => '/vagrant/tests/ssl/certs/sensu-backend.pem',
  ssl_key_source  => '/vagrant/tests/ssl/private_keys/sensu-backend.pem',
}
class { 'sensu::agent':
  backends => ['sensu-backend.example.com:8081'],
}
