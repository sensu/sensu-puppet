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

  if defined(Class['sensu::service::server']) {
    $notify_services = Class['sensu::service::server']
  } else {
    $notify_services = []
  }

  sensu_handler_config { $name:
    type    => $type,
    command => $command,
    ensure  => $ensure,
    notify  => $notify_services
  }
}
