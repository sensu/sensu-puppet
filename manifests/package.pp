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
  $use_embedded_ruby = 'true',
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

  file { 'sensu':
    ensure  => file,
    path    => '/etc/default/sensu',
    content => template("${module_name}/sensu.erb"),
    owner   => '0',
    group   => '0',
    mode    => '0644',
    require => Package['sensu'],
    notify  => $notify_services,
  }

  file { ['/etc/sensu/plugins', '/etc/sensu/handlers']:
    ensure  => directory,
    mode    => '0555',
    owner   => 'sensu',
    group   => 'sensu',
    require => Package['sensu'],
  }

  file { '/etc/sensu/config.json': ensure => absent }
}
