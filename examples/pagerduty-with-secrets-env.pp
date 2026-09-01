# Sensu Go docs: https://docs.sensu.io/sensu-go/latest/guides/secrets-management/
# Prerequisites: sensu-puppet module, PagerDuty integration key

# Replace INTEGRATION_KEY with your actual PagerDuty Events API v2 integration key
class { 'sensu':
  use_ssl => false,
}

class { 'sensu::backend':
  service_env_vars => { 'SENSU_PAGERDUTY_KEY' => 'INTEGRATION_KEY' },
}

include sensu::cli

sensu_secret { 'pagerduty_key in default':
  ensure           => 'present',
  id               => 'SENSU_PAGERDUTY_KEY',
  secrets_provider => 'env',
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
