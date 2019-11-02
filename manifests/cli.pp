# @summary Manage Sensu CLI
#
# Class to manage the Sensu CLI.
#
# @example
#   class { 'sensu::cli':
#     password => 'secret',
#   }
#
# @param version
#   Version of sensu-go-cli to install.  Defaults to `installed` to support
#   Windows MSI packaging and to avoid surprising upgrades.
# @param package_name
#   Name of Sensu CLI package.
# @param url_host
#   Sensu backend host used to configure sensuctl and verify API access.
# @param url_port
#   Sensu backend port used to configure sensuctl and verify API access.
# @param password
#   Sensu backend admin password used to confiure sensuctl.
# @param bootstrap
#   Should sensuctl be bootstrapped
# @param sensuctl_chunk_size
#   Chunk size to use when listing sensuctl resources
#
class sensu::cli (
  Optional[String] $version = undef,
  String $package_name = 'sensu-go-cli',
  String $url_host = $trusted['certname'],
  Stdlib::Port $url_port = 8080,
  String $password = 'P@ssw0rd!',
  Boolean $bootstrap = false,
  Optional[Integer] $sensuctl_chunk_size = undef,
) {

  include ::sensu

  $ssl_dir = $::sensu::ssl_dir
  $use_ssl = $::sensu::use_ssl
  $_version = pick($version, $::sensu::version)

  if $use_ssl {
    $url_protocol = 'https'
    $trusted_ca_file = $::sensu::trusted_ca_file_path
    Class['::sensu::ssl'] -> Sensu_configure['puppet']
  } else {
    $url_protocol = 'http'
    $trusted_ca_file = 'absent'
  }

  $url = "${url_protocol}://${url_host}:${url_port}"

  package { 'sensu-go-cli':
    ensure  => $_version,
    name    => $package_name,
    require => $::sensu::package_require,
  }

  sensuctl_config { 'sensu':
    chunk_size => $sensuctl_chunk_size,
  }

  sensu_configure { 'puppet':
    url                => $url,
    username           => 'admin',
    password           => $password,
    bootstrap          => $bootstrap,
    bootstrap_password => 'P@ssw0rd!',
    trusted_ca_file    => $trusted_ca_file,
  }

}
