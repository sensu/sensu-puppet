# = Class: sensu::enterprise::dashboard::api
#
# Manages the Sensu Enterprise API configuration
#
# == Parameters
#
# [*ensure*]
#   String. Whether the dashboard API should be configured or not
#   Default: present
#   Valid values: present, absent
#
# [*base_path*]
#   String. The base path to the client config file.
#   Default: undef
#
# [*host*]
#   String. The hostname or IP address of the Sensu API.
#   Default: undef
#
# [*port*]
#   Integer. The port of the Sensu API.
#   Default: unset
#
# [*ssl*]
#   Boolean. Whether or not to use the HTTPS protocol.
#   Default: undef
#
# [*insecure*]
#   Boolean. Whether or not to accept an insecure SSL certificate.
#   Default: undef
#
# [*path*]
#   String. The path of the Sensu API. Leave empty unless your Sensu API is not mounted to /.
#   Default: undef
#
# [*timeout*]
#   Integer. The timeout for the Sensu API, in seconds.
#   Default: undef
#
# [*user*]
#   String. The username of the Sensu API. Leave empty for no authentication.
#   Default: undef
#
# [*pass*]
#   String. The password of the Sensu API. Leave empty for no authentication.
#   Default: undef

define sensu::enterprise::dashboard::api (
  $ensure    = present,
  $base_path = undef,
  $host      = undef,
  $port      = undef,
  $ssl       = undef,
  $insecure  = undef,
  $path      = undef,
  $timeout   = undef,
  $user      = undef,
  $pass      = undef,
) {

  require ::sensu::enterprise::dashboard::config

  sensu_enterprise_dashboard_api_config { $title:
    ensure    => $ensure,
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
