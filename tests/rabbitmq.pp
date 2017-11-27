class {'::rabbitmq':
  # By default, rabbitmq creates a user guest:guest, however they can only authenticate from localhost
  # Delete the guest user since a sensu user will be created in the tests/rabbitmq.sh script
  delete_guest_user => true,
  config_ranch => false,
}
