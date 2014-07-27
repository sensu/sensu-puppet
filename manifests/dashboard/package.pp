# = Class: sensu::dashboard::package
#
# Install the Sensu dashboard package
#
class sensu::dashboard::package {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::dashboard and !is_bool($sensu::dashboard) {
    package { $sensu::dashboard :
      ensure => $sensu::dashboard_version,
    }
  }

}
