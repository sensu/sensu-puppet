# = Define: sensu::handler
#
# Defines Sensu handlers
#
# == Parameters
#

define sensu::handler(
  $type,
  $command,
  $ensure = 'present'
) {

  sensu_handler_config { $name:
    type    => $type,
    command => $command,
    ensure  => $ensure,
    notify  => Class['sensu::service::server']
  }
}
