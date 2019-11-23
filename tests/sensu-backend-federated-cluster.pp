class { '::sensu::backend':
  config_hash => {
    'etcd-listen-client-urls' => ["http://localhost:2379","http://${facts['networking']['interfaces']['eth1']['ip']}:2379"],
  }
}

if $facts['hostname'] =~ /peer2/ {
  sensu_etcd_replicator { 'role_replicator':
    ensure        => 'present',
    ca_cert       => '/etc/sensu/ssl/ca.crt',
    cert          => '/etc/sensu/ssl/cert.pem',
    key           => '/etc/sensu/ssl/key.pem',
    url           => 'http://192.168.52.30:2379',
    resource_name => 'Role',
  }
  sensu_role { 'test':
    ensure => 'present',
    rules  => [{'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => ['']}],
  }
}
