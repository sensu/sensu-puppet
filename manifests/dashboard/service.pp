# = Class: sensu::dashboard::service
#
# Manages the Sensu dashboard service
#
class sensu::dashboard::service {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::manage_services {

    case $sensu::dashboard {
      false: {
        $ensure = 'stopped'
        $enable = false
      }
      default: {
        $ensure = 'running'
        $enable = true
      }
    }

    if is_bool($sensu::dashboard) and $sensu::dashboard {
      $service_name_real = 'sensu-dashboard'
    } elsif !is_bool($sensu::dashboard) and $sensu::dashboard {
      $service_name_real = $sensu::dashboard
    }

    service { $service_name_real :
      ensure     => $ensure,
      enable     => $enable,
      hasrestart => true,
      subscribe  => [ Class['sensu::package'], Class['sensu::dashboard::package'],Class['sensu::dashboard::config'], Class['sensu::api::config'], Class['sensu::redis::config'] ]
    }
  }
}
