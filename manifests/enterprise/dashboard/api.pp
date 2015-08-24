define sensu::enterprise::dashboard::api (
  $base_path = undef,
  $host      = undef,
  $port      = undef,
  $ssl       = undef,
  $insecure  = undef,
  $path      = undef,
  $timeout   = undef,
  $user      = undef,
  $pass      = undef
) {

  require sensu::enterprise::dashboard::config

  sensu_enterprise_dashboard_api_config { $title:
    base_path => $base_path,
    host      => $host,
    port      => $port,
    ssl       => $ssl,
    insecure  => $insecure,
    path      => $path,
    timeout   => $timeout,
    user      => $user,
    pass      => $pass,
  }

}
