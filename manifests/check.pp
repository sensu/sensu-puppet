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
  $handlers             = undef,
  $standalone           = true,
  $interval             = '60',
  $subscribers          = undef,
  $low_flap_threshold   = undef,
  $high_flap_threshold  = undef,
  $custom               = undef,
) {

  $check_name = regsubst($name, ' ', '_', 'G')

  file { "/etc/sensu/conf.d/checks/${check_name}.json":
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0440',
    before  => Sensu_check[$check_name],
  }

  sensu_check { $check_name:
    ensure              => $ensure,
    type                => $type,
    standalone          => $standalone,
    command             => $command,
    handlers            => $handlers,
    interval            => $interval,
    subscribers         => $subscribers,
    low_flap_threshold  => $low_flap_threshold,
    high_flap_threshold => $high_flap_threshold,
    custom              => $custom,
    require             => File['/etc/sensu/conf.d/checks'],
  }

}
