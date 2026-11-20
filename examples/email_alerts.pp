# Sensu Go docs: https://docs.sensu.io/sensu-go/latest/guides/email-handler/
# Prerequisites: sensu-puppet module, SMTP server accessible from Sensu backend

# Replace these with your SMTP settings
$from     = 'YOUR-SENDER@example.com'
$to       = 'YOUR-RECIPIENT@example.com'
$server   = 'YOUR-SMTP-SERVER.example.com'
$username = 'USERNAME'
$password = 'PASSWORD'

class { 'sensu':
  use_ssl => false,
}

include sensu::backend
include sensu::cli

exec { 'add sensu-email-handler asset':
  path    => '/usr/bin:/bin:/usr/sbin:/sbin',
  command => 'sensuctl asset add sensu/sensu-email-handler',
  unless  => 'sensuctl asset info sensu/sensu-email-handler',
  require => Sensuctl_configure['puppet'],
}

exec { 'add check-cpu-usage asset':
  path    => '/usr/bin:/bin:/usr/sbin:/sbin',
  command => 'sensuctl asset add sensu/check-cpu-usage',
  unless  => 'sensuctl asset info sensu/check-cpu-usage',
  require => Sensuctl_configure['puppet'],
}

sensu_filter { 'state_change_only in default':
  ensure      => 'present',
  action      => 'allow',
  expressions => [
    'event.check.occurrences == 1',
  ],
}

sensu_handler { 'email in default':
  ensure         => 'present',
  type           => 'pipe',
  command        => "sensu-email-handler -f ${from} -t ${to} -s ${server} -u ${username} -p ${password}",
  filters        => [
    'is_incident',
    'not_silenced',
    'state_change_only',
  ],
  runtime_assets => ['sensu/sensu-email-handler'],
  require        => Exec['add sensu-email-handler asset'],
}

sensu_check { 'check_cpu':
  ensure         => 'present',
  command        => 'check-cpu-usage -w 75 -c 90',
  handlers       => ['email'],
  interval       => 30,
  publish        => true,
  subscriptions  => ['linux'],
  runtime_assets => ['sensu/check-cpu-usage'],
  require        => Exec['add check-cpu-usage asset'],
}
