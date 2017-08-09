# @summary Manages the Sensu Enterprise API configuration
#
# Manages the Sensu Enterprise API configuration
#
# @param host The hostname or IP address of the Sensu API.
#   This is used as the namevar for the underlying resource, so must be unique
#   within the catalog.
#
# @param ensure Whether the dashboard API should be configured or not
#
# @param base_path The base path to the client config file.
#
# @param datacenter The datacenter name.
#
# @param port The port of the Sensu API.
#
# @param ssl Whether or not to use the HTTPS protocol.
#
# @param insecure Whether or not to accept an insecure SSL certificate.
#
# @param path The path of the Sensu API. Leave empty unless your Sensu API is not mounted to /.
#
# @param timeout The timeout for the Sensu API, in seconds.
#
# @param user The username of the Sensu API. Leave empty for no authentication.
#
# @param pass The password of the Sensu API. Leave empty for no authentication.
#
define sensu::enterprise::dashboard::api (
  Enum['present','absent'] $ensure = present,
  Optional[String]  $base_path     = undef,
  Optional[String]  $datacenter    = undef,
  Optional[Integer] $port          = undef,
  Optional[Boolean] $ssl           = undef,
  Optional[Boolean] $insecure      = undef,
  Optional[String]  $path          = undef,
  Optional[Integer] $timeout       = undef,
  Optional[String]  $user          = undef,
  Optional[String]  $pass          = undef,
) {

  require ::sensu::enterprise::dashboard::config

  sensu_enterprise_dashboard_api_config { $title:
    ensure     => $ensure,
    base_path  => $base_path,
    datacenter => $datacenter,
    port       => $port,
    ssl        => $ssl,
    insecure   => $insecure,
    path       => $path,
    timeout    => $timeout,
    user       => $user,
    pass       => $pass,
  }

}
