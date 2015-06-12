# = Class: sensu::client::service
#
# Manages the Sensu client service
#
# == Parameters
#
# [*hasrestart*]
#   Bolean. Value of hasrestart attribute for this service.
#   Default: true
#
class sensu::client::service (
  $hasrestart = true,
) {

  validate_bool($hasrestart)

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::manage_services {

    case $sensu::client {
      true: {
        $ensure = 'running'
        $enable = true
      }
      default: {
        $ensure = 'stopped'
        $enable = false
      }
    }

    service { 'sensu-client':
      ensure     => $ensure,
      enable     => $enable,
      hasrestart => $hasrestart,
      subscribe  => [Class['sensu::package'], Class['sensu::client::config'], Class['sensu::rabbitmq::config'] ],
    }
  }
}
