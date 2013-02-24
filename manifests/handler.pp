# = Define: sensu::handler
#
# Defines Sensu handlers
#
# == Parameters
#

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
