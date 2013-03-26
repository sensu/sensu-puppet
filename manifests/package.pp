# = Class: sensu::package
#
# Installs the Sensu packages
#
# == Parameters
#

class sensu::package(
  $version          = 'latest',
  $notify_services  = [],
  $install_repo     = 'true',
  $purge_config     = 'false',
) {

  if $install_repo == 'true' or $install_repo == true {
    include sensu::repo
  }

  package { 'sensu':
    ensure  => $version,
    notify  => $notify_services
  }

  if $purge_config {
    file { '/etc/sensu/conf.d':
      purge   => true,
      recurse => true,
      force   => true,
    }
  }

  file { ['/etc/sensu/plugins', '/etc/sensu/handlers', '/etc/sensu/conf.d/checks']:
    ensure  => directory,
    mode    => '0555',
    owner   => 'sensu',
    group   => 'sensu',
    require => Package['sensu'],
  }

  file { '/etc/sensu/config.json': ensure => absent }
}
