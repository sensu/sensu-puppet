# = Class: sensu::service::client
#
# Manages Sensu client service
#
# == Parameters
#
class sensu::service::client (
  $enabled = 'stopped'
) {

  $real_ensure = $enabled ? {
    'true'  => 'running',
    true    => 'running',
    default => 'stopped',
  }

  service { 'sensu-client':
    ensure     => $real_ensure,
    enable     => $enabled,
    hasrestart => true,
  }

}
