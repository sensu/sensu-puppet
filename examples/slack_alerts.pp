# Sensu Go docs: https://docs.sensu.io/sensu-go/latest/guides/send-slack-alerts/
# Prerequisites: sensu-puppet module, Slack webhook URL

# Replace with your Slack incoming webhook URL and target channel
$webhook_url = 'https://hooks.slack.com/services/T0000/B000/XXXXXXXX'
$channel     = '#monitor'

class { 'sensu':
  use_ssl => false,
}

include sensu::backend
include sensu::cli

exec { 'add sensu-slack-handler asset':
  path    => '/usr/bin:/bin:/usr/sbin:/sbin',
  command => 'sensuctl asset add sensu/sensu-slack-handler',
  unless  => 'sensuctl asset info sensu/sensu-slack-handler',
  require => Sensuctl_configure['puppet'],
}

exec { 'add check-cpu-usage asset':
  path    => '/usr/bin:/bin:/usr/sbin:/sbin',
  command => 'sensuctl asset add sensu/check-cpu-usage',
  unless  => 'sensuctl asset info sensu/check-cpu-usage',
  require => Sensuctl_configure['puppet'],
}

sensu_handler { 'slack':
  ensure         => 'present',
  type           => 'pipe',
  env_vars       => ["SLACK_WEBHOOK_URL=${webhook_url}"],
  command        => "sensu-slack-handler --channel '${channel}'",
  runtime_assets => ['sensu/sensu-slack-handler'],
  require        => Exec['add sensu-slack-handler asset'],
}

sensu_check { 'check_cpu':
  ensure         => 'present',
  command        => 'check-cpu-usage -w 75 -c 90',
  handlers       => ['slack'],
  interval       => 30,
  publish        => true,
  subscriptions  => ['linux'],
  runtime_assets => ['sensu/check-cpu-usage'],
  require        => Exec['add check-cpu-usage asset'],
}
