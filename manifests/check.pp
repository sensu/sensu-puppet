# = Define: sensu::check
#
# Defines Sensu checks
#
# == Parameters
#

define sensu::check(
  $command,
  $handlers    = [],
  $interval    = '60',
  $standalone  = false,
  $aggregate   = false,
  $subscribers = []
) {

  sensu_check_config { $name:
    realname    => $name,
    command     => $command,
    handlers    => $handlers,
    interval    => $interval,
    standalone  => $standalone,
    aggregate   => $aggregate,
    subscribers => $subscribers,
  }

}
