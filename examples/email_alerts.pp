# Sensu Go docs: https://docs.sensu.io/sensu-go/latest/guides/email-handler/

include sensu::backend

sensu_bonsai_asset { 'sensu/sensu-email-handler':
  ensure  => 'present',
  version => 'latest',
  rename  => 'sensu-email-handler',
}

sensu_filter { 'state_change_only in default':
  ensure      => 'present',
  action      => 'allow',
  expressions => [
    'event.check.occurrences == 1',
  ],
}

$from = 'YOUR-SENDER@example.com'
$to = 'YOUR-RECIPIENT@example.com'
$server = 'YOUR-SMTP-SERVER.example.com'
$username = 'USERNAME'
$password = 'PASSWORD'
sensu_handler { 'email in default':
  type           => 'pipe',
  command        => "sensu-email-handler -f ${from} -t ${to} -s ${server} -u ${username} -p ${password}",
  filters        => [
    'is_incident',
    'not_silenced',
    'state_change_only',
  ],
  runtime_assets => ['sensu-email-handler'],
}

sensu_check { 'check_cpu':
  ensure         => 'present',
  command        => 'check-cpu.rb -w 75 -c 90',
  handlers       => ['email'],
  interval       => 30,
  publish        => true,
  subscriptions  => ['linux'],
  runtime_assets => ['sensu-plugins-cpu-checks','sensu-ruby-runtime'],
}
