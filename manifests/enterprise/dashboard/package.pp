# = Class: sensu::enterprise::dashboard::package
#
# Manages the sensu-enterprise-dashboard package
#
class sensu::enterprise::dashboard::package {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $::sensu::enterprise_dashboard {
    package { 'sensu-enterprise-dashboard':
      ensure => $::sensu::enterprise_dashboard_version,
    }
  }
}
