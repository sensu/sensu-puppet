# Sensu Go docs: https://docs.sensu.io/sensu-go/latest/guides/secrets-management/
# Prerequisites: sensu-puppet module, HashiCorp Vault instance accessible from Sensu backend
# Vault must have a secret at path 'secret/pagerduty' with key 'key'

# Replace with your Vault address and root token
class { 'sensu':
  use_ssl => false,
}

include sensu::backend
include sensu::cli

sensu_secrets_vault_provider { 'vault':
  ensure       => 'present',
  address      => 'http://vault.example.com:8200',
  token        => 'ROOT_TOKEN',
  version      => 'v2',
  max_retries  => 2,
  timeout      => '20s',
  rate_limiter => { 'limit' => 10, 'burst' => 100 },
}

sensu_secret { 'pagerduty_key in default':
  ensure           => 'present',
  id               => 'secret/pagerduty#key',
  secrets_provider => 'vault',
}

exec { 'add sensu-pagerduty-handler asset':
  path    => '/usr/bin:/bin:/usr/sbin:/sbin',
  command => 'sensuctl asset add sensu/sensu-pagerduty-handler',
  unless  => 'sensuctl asset info sensu/sensu-pagerduty-handler',
  require => Sensuctl_configure['puppet'],
}

sensu_handler { 'pagerduty in default':
  ensure         => 'present',
  type           => 'pipe',
  command        => 'pagerduty-handler --token $PD_TOKEN',
  secrets        => [
    {'name' => 'PD_TOKEN', 'secret' => 'pagerduty_key'},
  ],
  runtime_assets => ['sensu/sensu-pagerduty-handler'],
  timeout        => 10,
  filters        => ['is_incident'],
  require        => Exec['add sensu-pagerduty-handler asset'],
}
