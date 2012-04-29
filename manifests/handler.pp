define sensu::handler(
                      $type,
                      $command
                      ) {

  sensu_handler_config { $name:
    type    => $type,
    command => $command,
    before  => Service['sensu-server'],
  }
}
