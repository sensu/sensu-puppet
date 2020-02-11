# Sensu Go docs: https://docs.sensu.io/sensu-go/latest/guides/secrets-management/

class { 'sensu::backend':
  service_env_vars => { 'SENSU_PAGERDUTY_KEY' => 'INTEGRATION_KEY' },
}

sensu_secret { 'pagerduty_key in default':
  ensure           => 'present',
  id               => 'SENSU_PAGERDUTY_KEY',
  secrets_provider => 'env',
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
