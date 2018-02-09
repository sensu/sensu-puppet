# @summary Manages the Sensu server service
#
# Manages the Sensu server service
#
# @param hasrestart Value of hasrestart attribute for this service.
#
class sensu::server::service (
  Boolean $hasrestart    = $::sensu::hasrestart,
  $server_service_enable = $::sensu::server_service_enable,
  $server_service_ensure = $::sensu::server_service_ensure,
) {

  if $::sensu::manage_services {

    case $::sensu::server {
      true: {
        $ensure = $server_service_ensure
        $enable = $server_service_enable
      }
      default: {
        $ensure = 'stopped'
        $enable = false
      }
    }

    # The server is only supported on Linux
    if $::kernel == 'Linux' {
      service { 'sensu-server':
        ensure     => $ensure,
        enable     => $enable,
        hasrestart => $hasrestart,
        subscribe  => [
          Class['sensu::package'],
          Sensu_api_config[$::fqdn],
          Class['sensu::redis::config'],
          Class['sensu::rabbitmq::config'],
        ],
      }
    }
  }
}
