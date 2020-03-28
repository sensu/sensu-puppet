case $facts['networking']['hostname'] {
  /peer1/: {
    $backend_name = 'backend1'
  }
  /peer2/: {
    $backend_name = 'backend2'
  }
  default: {}
}

class { 'sensu':
  api_host => $facts['networking']['fqdn'],
}
class { 'sensu::backend':
  config_hash => {
    'etcd-advertise-client-urls'       => "http://${facts['networking']['interfaces']['eth1']['ip']}:2379",
    'etcd-listen-client-urls'          => "http://${facts['networking']['interfaces']['eth1']['ip']}:2379",
    'etcd-listen-peer-urls'            => 'http://0.0.0.0:2380',
    'etcd-initial-cluster'             => 'backend1=http://192.168.52.21:2380,backend2=http://192.168.52.22:2380',
    'etcd-initial-advertise-peer-urls' => "http://${facts['networking']['interfaces']['eth1']['ip']}:2380",
    'etcd-initial-cluster-state'       => 'new',
    'etcd-initial-cluster-token'       => '',
    'etcd-name'                        => $backend_name,
  },
}
