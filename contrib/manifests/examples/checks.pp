# Class: companyxsensu::checks
#
#
class examplesensu::checks {
  #checks for all hosts
  sensu::check { 'check_ntp':
    command     => 'PATH=$PATH:/usr/lib/nagios/plugins check_ntp_time -H pool.ntp.org -w 20 -c 40',
    handlers    => 'default',
    subscribers => 'companyx',
    standalone  => false,
    custom      => { occurrences => 2 },
  }
  sensu::check { 'check_disk':
    command     => 'PATH=$PATH:/usr/lib/nagios/plugins check_disk -w 15% -c 5%  -m',
    handlers    => 'default',
    subscribers => 'companyx',
    standalone  => false,
    custom      => { occurrences => 2 },
  }
  sensu::check { 'check_mem':
    command     => '/etc/sensu/plugins/check_mem.sh -w 85 -c 95',
    handlers    => 'default',
    subscribers => 'companyx',
    standalone  => false,
    custom      => { occurrences => 2 },
#    type        => 'metric'
  }
  sensu::check { 'check_cron':
    command     => '/etc/sensu/plugins/check-procs.rb -p cron -C 1 -c 10 -w 10 ',
    handlers    => 'default',
    subscribers => 'companyx',
    interval    => 60,
    standalone  => false,
    custom      => { occurrences => 2 },
  }

  # Webserver checks
  sensu::check { 'check_http_nginx':
    command     => 'PATH=$PATH:/usr/lib/nagios/plugins check_http -I localhost -H www.example.com -u /',
    handlers    => 'default',
    subscribers => 'webserver',
    standalone  => false,
    custom      => { occurrences => 2 },
  }
  sensu::check { 'check_http_uwsgi':
    command     => 'PATH=$PATH:/usr/lib/nagios/plugins check_http -I localhost -H www.example.com -u /status/',
    handlers    => 'default',
    subscribers => 'webserver',
    standalone  => false,
    custom      => { occurrences => 2 },
  }

  # sensu::check { 'mysql_graphite':
  #   command     => '/etc/sensu/plugins/mysql-graphite.rb -h localhost -u repl_check -p password',
  #   handlers    => 'relay',
  #   subscribers => 'mysql',
  #   standalone  => false,
  #   type        => 'metric'
  # }

  # logstash
  sensu::check { 'logstash-agent':
    command     => '/etc/sensu/plugins/check-procs.rb -p "logstash/agent" -C1',
    handlers    => 'default',
    subscribers => 'logstash',
    standalone  => false,
    custom      => { occurrences => 2 },
#    type        => 'metric'
  }
  sensu::check { 'elasticsearch':
    command     => '/etc/sensu/plugins/check-procs.rb -p "elasticsearch" -C1',
    handlers    => 'default',
    subscribers => 'logstash',
    standalone  => false,
    custom      => { occurrences => 2 },
  }

  #Server only
  sensu::check { 'check_http_ssl_expiration':
    command    => 'PATH=$PATH:/usr/lib/nagios/plugins check_http --ssl -C 14  -H www.example.com',
    handlers   => 'default',
    standalone => true
  }
}
