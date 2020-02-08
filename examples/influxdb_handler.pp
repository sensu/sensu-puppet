# Sensu Go docs: https://docs.sensu.io/sensu-go/latest/guides/influx-db-metric-handler/

$addr = 'http://influxdb.default.svc.cluster.local:8086'
$db_name = 'sensu'
$user = 'sensu'
$password = 'password'

include sensu::backend

sensu_bonsai_asset { 'sensu/sensu-influxdb-handler':
  ensure  => 'present',
  version => 'latest',
}

sensu_handler { 'influx-db':
  type           => 'pipe',
  env_vars       => [
    "INFLUXDB_ADDR=${addr}",
    "INFLUXDB_USER=${user}",
    "INFLUXDB_PASS=${password}",
  ],
  command        => "sensu-influxdb-handler -d ${db_name}",
  runtime_assets => ['sensu/sensu-influxdb-handler'],
}

sensu_check { 'collect-metrics':
  command                => 'collect_metrics.sh',
  output_metric_format   => 'influxdb_line',
  output_metric_handlers => ['influx-db'],
  interval               => 60,
  publish                => true,
  subscriptions          => ['linux'],
}
