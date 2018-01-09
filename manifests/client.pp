# @summary Manages the Sensu client service
#
# @param hasrestart Value of hasrestart attribute for this service.
#
# @param log_level Sensu log level to be used
#   Valid values: debug, info, warn, error, fatal
#
# @param windows_logrotate Whether or not to use logrotate on Windows OS family.
#
# @param windows_log_size The integer value for the size of log files on Windows OS family. sizeThreshold in sensu-client.xml.
#
# @param windows_log_number The integer value for the number of log files to keep on Windows OS family. keepFiles in sensu-client.xml.
#
class sensu::client (
  Boolean $hasrestart = $::sensu::hasrestart,
  $log_level          = $::sensu::log_level,
  $windows_logrotate  = $::sensu::windows_logrotate,
  $windows_log_size   = $::sensu::windows_log_size,
  $windows_log_number = $::sensu::windows_log_number,
) {

  # Service
  if $::sensu::manage_services {

    case $::sensu::client {
      true: {
        $service_ensure = 'running'
        $service_enable = true
      }
      default: {
        $service_ensure = 'stopped'
        $service_enable = false
      }
    }
    case $::osfamily {
      'windows': {
        $service_name     = 'sensu-client'
        $service_path     = undef
        $service_provider = undef
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
      'Darwin': {
        $service_path     = '/Library/LaunchDaemons/org.sensuapp.sensu-client.plist'
        $service_provider = 'launchd'

        file {$service_path:
          ensure => file,
          owner  => 'root',
          group  => 'wheel',
          mode   => '0755',
          before => Service['sensu-client'],
        }
      }
      default: {
        $service_path     = undef
        $service_provider = undef
      }
    }

    service { 'sensu-client':
      ensure     => $service_ensure,
      enable     => $service_enable,
      name       => $::sensu::service_name,
      hasrestart => $hasrestart,
      path       => $service_path,
      provider   => $service_provider,
      subscribe  => [
        Class['sensu::package'],
        Sensu_client_config[$::fqdn],
        Class['sensu::rabbitmq::config'],
      ],
    }
  }

  # Config
  if $::sensu::_purge_config and !$::sensu::client {
    $file_ensure = 'absent'
  } else {
    $file_ensure = 'present'
  }

  file { "${sensu::conf_dir}/client.json":
    ensure => $file_ensure,
    owner  => $::sensu::user,
    group  => $::sensu::group,
    mode   => $::sensu::file_mode,
  }

  $socket_config = {
    bind => $::sensu::client_bind,
    port => $::sensu::client_port,
  }

  sensu_client_config { $::fqdn:
    ensure         => $file_ensure,
    base_path      => $::sensu::conf_dir,
    client_name    => $::sensu::client_name,
    address        => $::sensu::client_address,
    socket         => $socket_config,
    subscriptions  => $::sensu::subscriptions,
    safe_mode      => $::sensu::safe_mode,
    custom         => $::sensu::client_custom,
    keepalive      => $::sensu::client_keepalive,
    redact         => $::sensu::redact,
    deregister     => $::sensu::client_deregister,
    deregistration => $::sensu::client_deregistration,
    registration   => $::sensu::client_registration,
    http_socket    => $::sensu::client_http_socket,
    servicenow     => $::sensu::client_servicenow,
    ec2            => $::sensu::client_ec2,
    chef           => $::sensu::client_chef,
    puppet         => $::sensu::client_puppet,
  }
}
