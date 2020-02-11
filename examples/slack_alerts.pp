# Sensu Go docs: https://docs.sensu.io/sensu-go/latest/guides/send-slack-alerts/

$webhook_url = 'https://hooks.slack.com/services/T0000/B000/XXXXXXXX'
$channel     = '#monitor'

include sensu::backend

sensu_bonsai_asset { 'sensu/sensu-slack-handler':
  ensure  => 'present',
  version => 'latest',
}

sensu_handler { 'slack':
  type           => 'pipe',
  env_vars       => ["SLACK_WEBHOOK_URL=${webhook_url}"],
  command        => "sensu-slack-handler --channel '${channel}'",
  runtime_assets => ['sensu/sensu-slack-handler'],
}

sensu_check { 'check_cpu':
  ensure         => 'present',
  command        => 'check-cpu.rb -w 75 -c 90',
  handlers       => ['slack'],
  interval       => 30,
  publish        => true,
  subscriptions  => ['linux'],
  runtime_assets => ['sensu-plugins-cpu-checks','sensu-ruby-runtime'],
}
