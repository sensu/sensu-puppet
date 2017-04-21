file { '/usr/bin/sensu_report':
  mode   => '0555',
  source => 'puppet:///files/sensu/sensu_report',
} ->
cron { 'sensu_report':
  command => "/usr/bin/sensu_report -s $sensu_api_server > /etc/motd",
  minute  => fqdn_rand(60),
} ->
sensu::check { "sensu_report":
  handlers    => 'default',
  command     => '/usr/lib/nagios/plugins/check_file_age -w 7200 -c 21600 -f /etc/motd',
  subscribers => 'sensu-test'
}