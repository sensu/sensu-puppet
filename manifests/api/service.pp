# = Class: sensu::api::service
#
# Manages the Sensu api service
#
class sensu::api::service {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::manage_services_real {

    case $sensu::api_real {
      true: {
        $ensure = 'running'
        $enable = true
      }
      default: {
        $ensure = 'stopped'
        $enable = false
      }
    }

    service { 'sensu-api':
      ensure    => $ensure,
      enable    => $enable,
      subscribe => [ Class['sensu::package'], Class['sensu::api::config'], Class['sensu::redis::config'] ]
    }
  }
}
