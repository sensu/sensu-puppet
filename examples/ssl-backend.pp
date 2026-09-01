# Example of Sensu backend with SSL/TLS enabled
# Prerequisites: SSL certificates generated and available on the node
# See: https://docs.sensu.io/sensu-go/latest/operations/deploy-sensu/secure-sensu/
#
# Certificate paths below assume Puppet-managed SSL certs. Adjust to match
# your certificate locations.

class { 'sensu':
  use_ssl       => true,
  ssl_ca_source => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
  api_host      => 'sensu-backend',
}

class { 'sensu::backend':
  ssl_cert_source => '/etc/puppetlabs/puppet/ssl/ca/signed/sensu-backend.pem',
  ssl_key_source  => '/etc/puppetlabs/puppet/ssl/private_keys/sensu-backend.pem',
}

include sensu::cli
