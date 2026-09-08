# Sensu Go docs: https://docs.sensu.io/sensu-go/latest/guides/influx-db-metric-handler/
# Prerequisites: sensu-puppet module, InfluxDB instance accessible from Sensu backend

# Replace these with your InfluxDB connection details
$addr     = 'http://influxdb.example.com:8086'
$db_name  = 'sensu'
$user     = 'sensu'
$password = 'password'

class { 'sensu':
  use_ssl => false,
}

include sensu::backend
include sensu::cli

exec { 'add sensu-influxdb-handler asset':
  path    => '/usr/bin:/bin:/usr/sbin:/sbin',
  command => 'sensuctl asset add sensu/sensu-influxdb-handler',
  unless  => 'sensuctl asset info sensu/sensu-influxdb-handler',
  require => Sensuctl_configure['puppet'],
}

exec { 'add check-cpu-usage asset':
  path    => '/usr/bin:/bin:/usr/sbin:/sbin',
  command => 'sensuctl asset add sensu/check-cpu-usage',
  unless  => 'sensuctl asset info sensu/check-cpu-usage',
  require => Sensuctl_configure['puppet'],
}

sensu_handler { 'influx-db':
  ensure         => 'present',
  type           => 'pipe',
  env_vars       => [
    "INFLUXDB_ADDR=${addr}",
    "INFLUXDB_USER=${user}",
    "INFLUXDB_PASS=${password}",
  ],
  command        => "sensu-influxdb-handler -d ${db_name}",
  runtime_assets => ['sensu/sensu-influxdb-handler'],
  require        => Exec['add sensu-influxdb-handler asset'],
}

sensu_check { 'collect-metrics':
  ensure                 => 'present',
  command                => 'check-cpu-usage --metrics',
  output_metric_format   => 'influxdb_line',
  output_metric_handlers => ['influx-db'],
  interval               => 60,
  publish                => true,
  subscriptions          => ['linux'],
  runtime_assets         => ['sensu/check-cpu-usage'],
  require                => Exec['add check-cpu-usage asset'],
}
