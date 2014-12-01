class {'::rabbitmq':
  # Caution: By default the guest user can only access the web portal from localhost. 
  # An additional sensu user will be created. See tests/rabbitmq.sh
  default_user => 'guest',
  default_pass => 'guest',
}