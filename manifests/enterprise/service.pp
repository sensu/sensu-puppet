# = Class: sensu::enterprise::service
#
# Manages the Sensu Enterprise server service
#
# == Parameters
#
# [*hasrestart*]
#   Boolean. Value of hasrestart attribute for this service.
#   Default: true

class sensu::enterprise::service (
  Boolean $hasrestart = true,
) {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $::sensu::manage_services and $::sensu::enterprise {

    case $::sensu::enterprise {
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
      service { 'sensu-enterprise':
        ensure     => $ensure,
        enable     => $enable,
        hasrestart => $hasrestart,
        subscribe  => [
          Class['sensu::enterprise::package'],
          Class['sensu::api::config'],
          Class['sensu::redis::config'],
          Class['sensu::rabbitmq::config'],
        ],
      }
    }
  }
}
