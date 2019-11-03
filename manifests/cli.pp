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
# @param install_source
#   Source of Sensu Go CLI download for installing on Windows.
#   Paths with http:// or https:// will be downloaded
#   Paths with puppet:// or file:// paths will also be installed.
# @param install_path
#   Where to install sensuctl for Windows. Default to `C:\Program Files\Sensu`.
# @param url_host
#   Sensu backend host used to configure sensuctl and verify API access.
# @param url_port
#   Sensu backend port used to configure sensuctl and verify API access.
# @param password
#   Sensu backend admin password used to confiure sensuctl.
# @param bootstrap
#   Should sensuctl be bootstrapped. This is a private parameter used by sensu::backend class.
# @param configure
#   Determines if sensuctl should be configured
# @param sensuctl_chunk_size
#   Chunk size to use when listing sensuctl resources
#
class sensu::cli (
  Optional[String] $version = undef,
  String $package_name = 'sensu-go-cli',
  Optional[Variant[Stdlib::HTTPSUrl, Stdlib::HTTPUrl, Pattern[/^(file|puppet):/]]] $install_source = undef,
  Optional[Stdlib::Absolutepath] $install_path = undef,
  String $url_host = $trusted['certname'],
  Stdlib::Port $url_port = 8080,
  String $password = 'P@ssw0rd!',
  Boolean $bootstrap = false,
  Boolean $configure = true,
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

  if $facts['os']['family'] == 'windows' {
    if ! $install_source {
      fail('sensu::cli: install_source is required for Windows')
    }
    $sensuctl_path = "${install_path}\\sensuctl.exe"
    file { $install_path:
      ensure => 'directory',
    }
    archive { 'sensu-go-cli.zip':
      path         => "${install_path}\\sensu-go-cli.zip",
      source       => $install_source,
      extract      => true,
      extract_path => $install_path,
      creates      => "${install_path}\\sensuctl.exe",
      cleanup      => false,
      require      => File[$install_path],
    }
    windows_env { 'sensuctl-path':
      ensure    => 'present',
      variable  => 'PATH',
      value     => $install_path,
      mergemode => 'append',
      require   => Archive['sensu-go-cli.zip'],
      before    => Sensu_configure['puppet'],
    }
  } else {
    $sensuctl_path = undef
    package { 'sensu-go-cli':
      ensure  => $_version,
      name    => $package_name,
      require => $::sensu::package_require,
    }
  }

  if $configure {
    sensuctl_config { 'sensu':
      chunk_size => $sensuctl_chunk_size,
      path       => $sensuctl_path,
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
}
