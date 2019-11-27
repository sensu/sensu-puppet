# @summary Manage Sensu API
#
# Class to manage the Sensu API.
#
# @example
#   include ::sensu::api
#
# @param url
#   The Sensu Go API URL. Defaults to $::sensu::api_url that is
#   based on parameters passed to sensu class
# @param username
#   The Sensu Go API username. Defaults to 'admin'
# @param password
#   The Sensu Go API password. Defaults to password set in sensu class
# @param old_password
#   The Sensu Go API old password. Defaults to old_password set in sensu class
#
class sensu::api (
  Optional[Variant[Stdlib::HTTPUrl, Stdlib::HTTPSUrl]] $url = undef,
  Optional[String] $username = undef,
  Optional[String] $password = undef,
  Optional[String] $old_password = undef,
) {
  include ::sensu

  $_url = pick($url, $::sensu::api_url)
  $_username = pick($username, 'admin')
  $_password = pick($password, $::sensu::password)
  if $::sensu::old_password {
    $_old_password = pick($old_password, $::sensu::old_password)
  } else {
    $_old_password = $old_password
  }

  sensu_api_config { 'sensu':
    url          => $_url,
    username     => $_username,
    password     => $_password,
    old_password => $_old_password,
  }
}
