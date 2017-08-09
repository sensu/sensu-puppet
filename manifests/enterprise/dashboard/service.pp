# @summary Installs the Sensu Enterprise Dashboard
#
# Installs the Sensu Enterprise Dashboard
#
class sensu::enterprise::dashboard::service (
  Boolean $hasrestart = true,
) {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $::sensu::manage_services and $::sensu::enterprise_dashboard {

    case $::sensu::enterprise_dashboard {
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
}
