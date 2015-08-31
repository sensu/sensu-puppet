# = Class: sensu::enterprise::dashboard
#
# Installs the Sensu Enterprise Dashboard
class sensu::enterprise::dashboard::service (
  $hasrestart = true,
) {

  validate_bool($hasrestart)

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $::sensu::enterprise_dashboard {
    case $::sensu::manage_services {
      true: {
        $ensure = 'running'
        $enable = true
      }
      default: {
        $ensure = 'stopped'
        $enable = false
      }
    }

    service { 'sensu-enterprise-dashboard':
      ensure     => $ensure,
      enable     => $enable,
      hasrestart => $hasrestart,
      subscribe  => [
        Class['sensu::enterprise::dashboard::package'],
        Class['sensu::enterprise::dashboard::config'],
        Class['sensu::redis::config'],
      ],
    }

  }
}
