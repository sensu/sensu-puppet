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
) {

  file { "/etc/sensu/conf.d/checks/config_${name}.json":
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0444',
    before  => Sensu_check[$name],
  }

  sensu_check_config { $name:
    ensure => $ensure,
    config => $config,
    event  => $event,
  }

}
