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

  Service {
    ensure     => $real_ensure,
    enable     => $enabled,
    hasrestart => true,
  }

  service { 'sensu-server': }
  service { 'sensu-api': }
  service { 'sensu-dashboard': }
}
