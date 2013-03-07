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
  $standalone           = true,
  $interval             = '60',
  $subscribers          = [],
  $notification         = undef,
  $low_flap_threshold   = undef,
  $high_flap_threshold  = undef,
  $refresh              = undef,
  $aggregate            = false,
  $config               = '',
  $config_key           = $name,
) {

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

  sensu_check_config { $config_key:
    ensure  => $config_present,
    config  => $config,
  }

}
