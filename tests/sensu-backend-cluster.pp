case $facts['hostname'] {
  /peer1/: {
    $backend_name = 'backend1'
  }
  /peer2/: {
    $backend_name = 'backend2'
  }
}

class { '::sensu::backend':
  config_hash => {
    'listen-client-urls'          => 'http://0.0.0.0:2379',
    'listen-peer-urls'            => 'http://0.0.0.0:2380',
    'initial-cluster'             => 'backend1=http://192.168.52.21:2380,backend2=http://192.168.52.22:2380',
    'initial-advertise-peer-urls' => "http://${facts['networking']['interfaces']['eth1']['ip']}:2380",
    'initial-cluster-state'       => 'new',
    'name'                        => $backend_name,
  }
}

