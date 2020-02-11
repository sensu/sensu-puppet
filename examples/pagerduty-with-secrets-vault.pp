# Sensu Go docs: https://docs.sensu.io/sensu-go/latest/guides/secrets-management/

include sensu::backend

sensu_secrets_vault_provider { 'vault':
  ensure       => 'present',
  address      => 'http://localhost:8200',
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

sensu_bonsai_asset { 'sensu/sensu-pagerduty-handler':
  ensure  => 'present',
  version => 'latest',
  rename  => 'pagerduty-handler',
}

sensu_handler { 'pagerduty in default':
  ensure         => 'present',
  type           => 'pipe',
  command        => 'pagerduty-handler --token $PD_TOKEN',
  secrets        => [
    {'name' => 'PD_TOKEN', 'secret' => 'pagerduty_key'},
  ],
  runtime_assets => ['pagerduty-handler'],
  timeout        => 10,
  filters        => ['is_incident'],
}
