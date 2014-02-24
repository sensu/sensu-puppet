# = Class: sensu::client::service
#
# Manages the Sensu client service
#
class sensu::client::service {


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
      hasstatus  => true,
      hasrestart => true,
      subscribe  => [Class['sensu::package'], Class['sensu::client::config'], Class['sensu::rabbitmq::config'] ],
    }
  }
}
