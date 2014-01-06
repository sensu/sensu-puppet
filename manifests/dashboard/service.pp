# = Class: sensu::dashboard::service
#
# Manages the Sensu dashboard service
#
class sensu::dashboard::service {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::manage_services_real {

    case $sensu::dashboard_real {
      true: {
        $ensure = 'running'
        $enable = true
      }
      default: {
        $ensure = 'stopped'
        $enable = false
      }
    }

    service { 'sensu-dashboard':
      ensure    => $ensure,
      enable    => $enable,
      subscribe => [ Class['sensu::package'], Class['sensu::dashboard::config'], Class['sensu::api::config'], Class['sensu::redis::config'] ]
    }
  }
}
