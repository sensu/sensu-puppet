# @summary Manage Sensu backend
#
# Class to manage the Sensu backend.
#
# @param version
#   Version of sensu backend to install.  Defaults to `installed` to support
#   Windows MSI packaging and to avoid surprising upgrades.
# @param package_name
#   Name of Sensu backend package. Defaults to `sensu-backend`.
# @param cli_package_name
#   Name of Sensu CLI package. Defaults to `sensu-cli`.
# @param service_name
#   Name of the Sensu backend service. Defaults to `sensu-backend`.
# @param service_ensure
#   Sensu backend service ensure value. Defaults to `running`.
# @param service_enable
#   Sensu backend service enable value. Defaults to `true`
# @param config_hash
#   Sensu backend configuration hash used to define backend.yml. Defaults to `{}`
# @param url_host
#   Sensu backend host used to configure sensuctl and verify API access.
#   Defaults to `127.0.0.1`.
# @param url_port
#   Sensu backend port used to configure sensuctl and verify API access.
#   Defaults to `8080`.
# @param username
#   Sensu backend admin username used to confiure sensuctl.
#   Default to `admin`.
# @param password
#   Sensu backend admin password used to confiure sensuctl.
#   Default to `P@ssw0rd!`
# @param bcrypt_dependencies
#   Array of packages needed to install bcrypt rubygem.
#
class sensu::backend (
  Optional[String] $version = undef,
  String $package_name = 'sensu-backend',
  String $cli_package_name = 'sensu-cli',
  String $service_name = 'sensu-backend',
  String $service_ensure = 'running',
  Boolean $service_enable = true,
  Hash $config_hash = {},
  String $url_host = '127.0.0.1',
  Stdlib::Port $url_port = 8080,
  String $username = 'admin',
  String $password = 'P@ssw0rd!',
  Array $bcrypt_dependencies = ['make','gcc']
) {

  include ::sensu

  $etc_dir = $::sensu::etc_dir

  $url = "http://${url_host}:${url_port}"

  if $version == undef {
    $_version = $::sensu::version
  } else {
    $_version = $version
  }

  if ! empty($bcrypt_dependencies) {
    ensure_packages($bcrypt_dependencies)
    $bcrypt_dependencies.each |$p| {
      Package[$p] -> Package['bcrypt']
    }
  }
  package { 'bcrypt':
    ensure   => 'installed',
    provider => 'puppet_gem',
  }
  Package['bcrypt'] -> Sensu_user<| |> # lint:ignore:spaceship_operator_without_tag

  package { 'sensu-cli':
    ensure  => $_version,
    name    => $cli_package_name,
    require => Class['::sensu::repo'],
  }

  sensu_api_validator { 'sensu':
    sensu_api_server => $url_host,
    sensu_api_port   => $url_port,
    require          => Service['sensu-backend'],
  }
  # Ensure sensu-backend is up before starting sensu-agent
  Sensu_api_validator['sensu'] -> Service['sensu-agent']

  $sensuctl_configure = "sensuctl configure -n --url '${url}' --username '${username}' --password 'P@ssw0rd!'"
  $sensuctl_configure_creates = '/root/.config/sensu/sensuctl/cluster'
  exec { 'sensuctl_configure':
    command => "${sensuctl_configure} || rm -f ${sensuctl_configure_creates}",
    creates => $sensuctl_configure_creates,
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    require => Sensu_api_validator['sensu'],
  }
  sensu_user { 'admin':
    ensure        => 'present',
    password      => $password,
    roles         => ['admin'],
    disabled      => false,
    configure     => true,
    configure_url => $url,
    require       => Exec['sensuctl_configure'],
  }

  package { 'sensu-backend':
    ensure  => $_version,
    name    => $package_name,
    before  => File['sensu_etc_dir'],
    require => Class['::sensu::repo'],
  }

  file { 'sensu_backend_config':
    ensure  => 'file',
    path    => "${etc_dir}/backend.yml",
    content => to_yaml($config_hash),
    require => Package['sensu-backend'],
    notify  => Service['sensu-backend'],
  }

  service { 'sensu-backend':
    ensure => $service_ensure,
    enable => $service_enable,
    name   => $service_name,
    before => Service['sensu-agent'],
  }
}
