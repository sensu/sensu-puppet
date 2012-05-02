define sensu::check(
                    $command,
                    $handlers    = [],
                    $interval    = '60',
                    $subscribers = []
                    ) {

  @@sensu_check_config { "${::fqdn}_${name}":
    realname    => $name,
    command     => $command,
    handlers    => $handlers,
    interval    => $interval,
    subscribers => $subscribers,
  }

  sensu_check_config { $name:
    realname    => $name,
    command     => $command,
    handlers    => $handlers,
    interval    => $interval,
    subscribers => $subscribers,
  }
}
