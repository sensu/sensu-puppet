# = Define: sensu::check
#
# Defines Sensu checks
#
# == Parameters
#

define sensu::check(
  $command,
  $ensure               = 'present',
  $type                 = undef,
  $handlers             = [],
  $standalone           = undef,
  $interval             = '60',
  $subscribers          = [],
  $notification         = undef,
  $low_flap_threshold   = undef,
  $high_flap_threshold  = undef,
  $refresh              = undef,
  $aggregate            = undef,
  $config               = '',
  $config_key           = $name,
  $purge_config         = 'false',
) {

  # Handler config
  case $ensure {
    'present': {
      $config_present = $config ? {
        ''      => 'absent',
        default => 'present'
      }
    }
    default: {
      $config_present = 'absent'
    }
  }

  if $purge_config {
    file { "/etc/sensu/conf.d/check_${name}.json": ensure => $ensure, before => sensu_check[$name] }
    file { "/etc/sensu/conf.d/${config_key}.json": ensure => $config_present, before => sensu_check_config[$config_key] }
  }

  sensu_check { $name:
    ensure              => $ensure,
    realname            => $name,
    type                => $type,
    standalone          => $standalone,
    command             => $command,
    handlers            => $handlers,
    interval            => $interval,
    subscribers         => $subscribers,
    notification        => $notification,
    low_flap_threshold  => $low_flap_threshold,
    high_flap_threshold => $high_flap_threshold,
    refresh             => $refresh,
    aggregate           => $aggregate,
  }

  sensu_check_config { $config_key:
    ensure  => $config_present,
    config  => $config,
  }

}
