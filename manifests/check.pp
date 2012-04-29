define sensu::check(
                    $command,
                    $handlers    = [],
                    $interval    = '60',
                    $subscribers = []
                    ) {

  sensu_check_config { $name:
    command     => $command,
    handlers    => $handlers,
    interval    => $interval,
    subscribers => $subscribers,
  }
}
