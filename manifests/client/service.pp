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

    if $::osfamily == 'windows' {

      file { 'C:/opt/sensu/bin/sensu-client.xml':
        ensure  => present,
        content => template("${module_name}/sensu-client.erb"),
      }

      $startup_type = $::os_maj_version ? {
        '2003'  => 'Automatic',
        default => 'Delayed-Auto',
      }

      exec { 'install-sensu-client':
        command => "powershell.exe -ExecutionPolicy RemoteSigned -Command \"New-Service -Name sensu-client -BinaryPathName c:\\opt\\sensu\\bin\\sensu-client.exe -DisplayName 'Sensu Client' -StartupType ${startup_type}\"",
        unless  => 'powershell.exe -ExecutionPolicy RemoteSigned -Command "Get-Service sensu-client"',
        path    => $::path,
        before  => Service['sensu-client'],
        require => File['C:/opt/sensu/bin/sensu-client.xml'],
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
