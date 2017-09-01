# @summary Manages the Sensu server service
#
# Manages the Sensu server service
#
# @param hasrestart Value of hasrestart attribute for this service.
#
class sensu::server::service (
  Boolean $hasrestart = $::sensu::hasrestart,
) {

  if $::sensu::manage_services {

    case $::sensu::server {
      true: {
        $ensure = 'running'
        $enable = true
      }
      default: {
        $ensure = 'stopped'
        $enable = false
      }
    }

    if $::osfamily !~ /(windows|Darwin)/ {
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
