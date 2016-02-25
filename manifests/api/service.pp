# = Class: sensu::api::service
#
# Manages the Sensu api service
#
# == Parameters
#
# [*hasrestart*]
#   Boolean. Value of hasrestart attribute for this service.
#   Default: true
#
class sensu::api::service (
  $hasrestart = true,
) {

  validate_bool($hasrestart)

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::manage_services {

    case $sensu::api {
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
      service { 'sensu-api':
        ensure     => $ensure,
        enable     => $enable,
        hasrestart => $hasrestart,
        subscribe  => [ Class['sensu::package'], Class['sensu::api::config'], Class['sensu::redis::config'] ],
      }
    }
  }
}
