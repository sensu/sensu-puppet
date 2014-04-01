# Class: examplesensu
#
#
class examplesensu {
#install sensu client, then plugins
class { 'sensu':
  rabbitmq_password        => 'abc123',
  rabbitmq_ssl_cert_chain  => "puppet:///modules/${module_name}/client/cert.pem",
  rabbitmq_ssl_private_key => "puppet:///modules/${module_name}/client/key.pem",
  subscriptions            => 'companyx',
  rabbitmq_port            => '5671',  # Use SSL port
  # client_custom            => {
  #   'env'                  => $env,
  #   'branch'               => $branch,
  #   'zone'                 => $ec2_placement_availability_zone,
  #   }
  }
  -> 
  class {'examplesensu::plugins':}
}
