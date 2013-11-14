# = Class: sensu::service::server
#
# Manages Sensu server service
#
# == Parameters
#
class sensu::service::server(
  $enabled = 'stopped'
) {

  $real_ensure = $enabled ? {
    'true'  => 'running',
    true    => 'running',
    default => 'stopped',
  }

  if $sensu::manage_services == 'true' or $sensu::manage_services == true {

    Service {
      ensure     => $real_ensure,
      enable     => $enabled,
      hasrestart => true,
    }

    service { 'sensu-server': }
    service { 'sensu-api': }
    service { 'sensu-dashboard': }

  }

}
