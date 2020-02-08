# Sensu Go docs: https://docs.sensu.io/sensu-go/latest/guides/systemd-logs/

include sensu::backend
include sensu::agent
include rsyslog::client

class { 'systemd':
  journald_settings => { 'ForwardToSyslog' => 'yes' },
}

rsyslog::snippet { '99-sensu-backend':
  ensure  => 'present',
  content => join([
    'if $programname == "sensu-backend" then {',
    '    /var/log/sensu/sensu-backend.log',
    '    ~',
    '}',
  ], "\n"),
}

rsyslog::snippet { '99-sensu-agent':
  ensure  => 'present',
  content => join([
    'if $programname == "sensu-agent" then {',
    '    /var/log/sensu/sensu-agent.log',
    '    ~',
    '}',
  ], "\n"),
}

logrotate::rule { 'sensu-backend':
  path          => '/var/log/sensu/sensu-backend.log',
  rotate_every  => 'day',
  rotate        => 7,
  size          => '100M',
  compress      => true,
  delaycompress => true,
  # Adjust PID file path. Following example works for CentOS/RHEL
  postrotate    => '/bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true',
}

logrotate::rule { 'sensu-agent':
  path          => '/var/log/sensu/sensu-agent.log',
  rotate_every  => 'day',
  rotate        => 7,
  size          => '100M',
  compress      => true,
  delaycompress => true,
  # Adjust PID file path. Following example works for CentOS/RHEL
  postrotate    => '/bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true',
}
