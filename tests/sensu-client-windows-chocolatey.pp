# Note: Check http://repositories.sensuapp.org/msi/ for the latest version.
node default {
  class { '::sensu':
    windows_package_provider => 'chocolatey',
    rabbitmq_password        => 'correct-horse-battery-staple',
    rabbitmq_host            => '192.168.56.10',
    rabbitmq_vhost           => '/sensu',
    subscriptions            => 'all',
    client_address           => $facts['networking']['ip'],
  }
}
