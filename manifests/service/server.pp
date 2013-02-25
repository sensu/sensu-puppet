class sensu::service::server(
  $enabled
) {

  $real_ensure = $enabled ? {
    'true'  => 'running',
    true    => 'running',
    default => 'stopped',
  }

  Service {
    ensure     => $real_enabled,
    enable     => $enabled,
    hasrestart => true,
  }

  service { 'sensu-server': }
  service { 'sensu-api': }
  service { 'sensu-dashboard': }
}
