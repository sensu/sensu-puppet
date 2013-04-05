# = Define: sensu::config
#
# Defines Sensu check configurations
#
# == Parameters
#

define sensu::config (
  $ensure       = 'present',
  $config       = undef,
  $event        = undef,
  $purge_config = undef,
) {

  if $purge_config {
    file { "/etc/sensu/conf.d/checks/config_${name}.json": ensure => $ensure, before => Sensu_check[$name] }
  }

  sensu_check_config { $name:
    ensure => $ensure,
    config => $config,
    event  => $event,
  }

}
