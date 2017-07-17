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
# [*log_level*]
#   String.  Sensu log level to be used
#   Default: $::sensu::log_level
#   Valid values: debug, info, warn, error, fatal
#
# [*windows_logrotate*]
#   Boolean. Whether or not to use logrotate on Windows OS family.
#   Default: $::sensu::windows_logrotate
#
# [*windows_log_size*]
#   Integer. The integer value for the size of log files on Windows OS family. sizeThreshold in sensu-client.xml.
#   Default: $::sensu::windows_log_size
#
# [*windows_log_number*]
#   Integer. The integer value for the number of log files to keep on Windows OS family. keepFiles in sensu-client.xml.
#   Default: $::sensu::windows_log_number
#
class sensu::client::service (
  Boolean $hasrestart = true,
  $log_level          = $::sensu::log_level,
  $windows_logrotate  = $::sensu::windows_logrotate,
  $windows_log_size   = $::sensu::windows_log_size,
  $windows_log_number = $::sensu::windows_log_number,
) {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $::sensu::manage_services {

    case $::sensu::client {
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
        ensure  => file,
        content => template("${module_name}/sensu-client.erb"),
      }

      exec { 'install-sensu-client':
        provider => 'powershell',
        command  => "New-Service -Name sensu-client -BinaryPathName c:\\opt\\sensu\\bin\\sensu-client.exe -DisplayName 'Sensu Client' -StartupType Automatic",
        unless   => 'if (Get-Service sensu-client -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }',
        before   => Service['sensu-client'],
        require  => File['C:/opt/sensu/bin/sensu-client.xml'],
      }
    }

    service { 'sensu-client':
      ensure     => $ensure,
      enable     => $enable,
      hasrestart => $hasrestart,
      subscribe  => [
        Class['sensu::package'],
        Class['sensu::client::config'],
        Class['sensu::rabbitmq::config'],
      ],
    }
  }
}
