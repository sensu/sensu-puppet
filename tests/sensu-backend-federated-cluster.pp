file { '/etc/sensu/etcd-ssl':
  ensure  => 'directory',
  source  => '/vagrant/tests/etcd-ssl',
  recurse => true,
  purge   => true,
  force   => true,
  before  => Service['sensu-backend'],
}

class { 'sensu':
  api_host => $facts['networking']['fqdn'],
}
class { 'sensu::backend':
  config_hash => {
    'etcd-listen-client-urls'    => 'https://0.0.0.0:2379',
    'etcd-advertise-client-urls' => "https://${facts['networking']['interfaces']['eth1']['ip']}:2379",
    'etcd-cert-file'             => "/etc/sensu/etcd-ssl/${trusted['certname']}.pem",
    'etcd-key-file'              => "/etc/sensu/etcd-ssl/${trusted['certname']}-key.pem",
    'etcd-trusted-ca-file'       => '/etc/sensu/etcd-ssl/ca.pem',
    'etcd-client-cert-auth'      => true,
  },
}

if $facts['networking']['hostname'] =~ /peer2/ {
  sensu_etcd_replicator { 'role_replicator':
    ensure        => 'present',
    ca_cert       => '/etc/sensu/etcd-ssl/ca.pem',
    cert          => '/etc/sensu/etcd-ssl/client.pem',
    key           => '/etc/sensu/etcd-ssl/client-key.pem',
    url           => 'https://192.168.52.30:2379',
    resource_name => 'Role',
  }
  sensu_role { 'test':
    ensure => 'present',
    rules  => [{'verbs' => ['get','list'], 'resources' => ['checks'], 'resource_names' => ['']}],
  }
}
