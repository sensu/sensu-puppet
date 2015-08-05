# = Class: sensu::package
#
# Installs the Sensu packages
#
class sensu::enterprise::package {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $::sensu::enterprise {

    package { 'sensu-enterprise':
      ensure  => $sensu::enterprise_version,
    }

    file { '/etc/default/sensu-enterprise':
      ensure  => file,
      content => template("${module_name}/sensu.erb"),
      owner   => '0',
      group   => '0',
      mode    => '0444',
      require => Package['sensu-enterprise'],
    }
  }

}
