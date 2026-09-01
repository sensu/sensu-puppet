# Sensu Go docs: https://docs.sensu.io/sensu-go/latest/guides/systemd-logs/
# Prerequisites: puppet-rsyslog module, puppet-logrotate module, puppet/systemd module

class { 'sensu':
  use_ssl => false,
}

include sensu::backend
include sensu::agent

class { 'systemd':
  journald_settings => { 'ForwardToSyslog' => 'yes' },
}

class { 'rsyslog::config':
  custom_config => {
    '99-sensu-backend' => {
      priority => 99,
      target   => '99-sensu-backend.conf',
      content  => @(RSYSLOG),
        if $programname == "sensu-backend" then {
            action(type="omfile" file="/var/log/sensu/sensu-backend.log")
            stop
        }
        | RSYSLOG
    },
    '99-sensu-agent'   => {
      priority => 99,
      target   => '99-sensu-agent.conf',
      content  => @(RSYSLOG),
        if $programname == "sensu-agent" then {
            action(type="omfile" file="/var/log/sensu/sensu-agent.log")
            stop
        }
        | RSYSLOG
    },
  },
}

logrotate::rule { 'sensu-backend':
  path          => '/var/log/sensu/sensu-backend.log',
  rotate_every  => 'day',
  rotate        => 7,
  size          => '100M',
  compress      => true,
  delaycompress => true,
  postrotate    => '/bin/kill -HUP $(cat /var/run/syslogd.pid 2>/dev/null) 2>/dev/null || true',
}

logrotate::rule { 'sensu-agent':
  path          => '/var/log/sensu/sensu-agent.log',
  rotate_every  => 'day',
  rotate        => 7,
  size          => '100M',
  compress      => true,
  delaycompress => true,
  postrotate    => '/bin/kill -HUP $(cat /var/run/syslogd.pid 2>/dev/null) 2>/dev/null || true',
}
