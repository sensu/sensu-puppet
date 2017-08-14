# @summary Manages the Sensu server service
#
# Manages the Sensu server service
#
# @param hasrestart Value of hasrestart attribute for this service.
#
class sensu::server::service (
  Boolean $hasrestart = true,
) {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $::sensu::manage_services {

    case $::sensu::server {
      true: {
        $ensure = 'running'
        $enable = true
      }
      default: {
        $ensure = 'stopped'
        $enable = false
      }
    }

    if $::osfamily != 'windows' {
      service { 'sensu-server':
        ensure     => $ensure,
        enable     => $enable,
        hasrestart => $hasrestart,
        subscribe  => [
          Class['sensu::package'],
          Class['sensu::api::config'],
          Class['sensu::redis::config'],
          Class['sensu::rabbitmq::config'],
        ],
      }
    }
  }
}
