##
# This class exercises the Dashboard API behavior in
# https://github.com/sensu/sensu-puppet/issues/638
# https://github.com/sensu/sensu-puppet/pull/651
#
# Usage:
# Bring up the sensu-server Vagrant vm.
# After provisioning completes, run:
# puppet apply -v /vagrant/tests/sensu-dashboard-api.pp
node 'sensu-server' {
  # This configuration is expected to produce /etc/sensu/dashboard.json with the values of:
  # name: example-dc
  # host: sensu.example.com

  if ! ($facts['se_user'] or $facts['se_pass']) {
    fail 'Provide Sensu Enterprise Credentials using FACTER_SE_USER and FACTER_SE_PASS environment variables.'
  }

  # Avoid /etc/sensu/dashboard.d/.keep from install of
  # sensu-enterprise-dashboard-1:2.8.1-1.x86_64 conflicts with file from
  # package uchiwa-1:0.25.2-1.x86_64
  package { 'uchiwa':
    ensure => absent,
    before => Class['sensu'],
  }

  class { '::sensu':
    install_repo         => true,
    server               => true,
    manage_services      => true,
    manage_user          => true,
    rabbitmq_password    => 'correct-horse-battery-staple',
    rabbitmq_vhost       => '/sensu',
    api                  => true,
    api_user             => 'admin',
    api_password         => 'secret',
    client_address       => $::ipaddress_eth1,
    enterprise_dashboard => true,
    enterprise_user      => $facts['se_user'],
    enterprise_pass      => $facts['se_pass'],
  }

  resources { 'sensu_enterprise_dashboard_api_config':
    purge => true,
  }

  sensu::enterprise::dashboard::api { 'sensu.example.net':
    datacenter => 'example-dc',
  }

  sensu::enterprise::dashboard::api { 'sensu.example.io':
    datacenter => 'example-dc',
  }
}
