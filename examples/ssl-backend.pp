# Example of Sensu backend with SSL enabled
#
# This example demonstrates how to configure a Sensu backend with SSL/TLS
# using the test certificates from /etc/puppetlabs/puppet/ssl/

class { 'sensu':
  use_ssl       => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
  api_host      => 'sensu-backend',
}

class { 'sensu::backend':
  ssl_cert_source => '/etc/puppetlabs/puppet/ssl/ca/signed/sensu-backend.pem',
  ssl_key_source  => '/etc/puppetlabs/puppet/ssl/private_keys/sensu-backend_key.pem',
}

include sensu::cli
