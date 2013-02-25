class sensu::service::client (
  $enabled
) {

  $real_ensure = $enabled ? {
    true  => 'running',
    false => 'stopped',
  }

  service { 'sensu-client':
    ensure     => $real_ensure,
    enable     => $enabled,
    hasrestart => true,
  }

}
