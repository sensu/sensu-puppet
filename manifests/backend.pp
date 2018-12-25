# @summary Manage Sensu backend
#
# Class to manage the Sensu backend.
#
# @example
#   class { 'sensu::backend':
#     password => 'secret',
#   }
#
# @param version
#   Version of sensu backend to install.  Defaults to `installed` to support
#   Windows MSI packaging and to avoid surprising upgrades.
# @param package_name
#   Name of Sensu backend package.
# @param cli_package_name
#   Name of Sensu CLI package.
# @param service_name
#   Name of the Sensu backend service.
# @param service_ensure
#   Sensu backend service ensure value.
# @param service_enable
#   Sensu backend service enable value.
# @param state_dir
#   Sensu backend state directory path.
# @param config_hash
#   Sensu backend configuration hash used to define backend.yml.
# @param url_host
#   Sensu backend host used to configure sensuctl and verify API access.
# @param url_port
#   Sensu backend port used to configure sensuctl and verify API access.
# @param use_ssl
#   Sensu backend service uses SSL
#
class sensu::backend (
  Optional[String] $version = undef,
  String $package_name = 'sensu-go-backend',
  String $cli_package_name = 'sensu-go-cli',
  String $service_name = 'sensu-backend',
  String $service_ensure = 'running',
  Boolean $service_enable = true,
  Stdlib::Absolutepath $state_dir = '/var/lib/sensu/sensu-backend',
  Hash $config_hash = {},
  String $url_host = '127.0.0.1',
  Stdlib::Port $url_port = 8080,
  Boolean $use_ssl = false,
) {

  include ::sensu

  $etc_dir = $::sensu::etc_dir

  $default_config = {
    'state-dir' => $state_dir,
  }
  $config = $default_config + $config_hash

  $url = "http://${url_host}:${url_port}"

  if $version == undef {
    $_version = $::sensu::version
  } else {
    $_version = $version
  }

  package { 'sensu-go-cli':
    ensure  => $_version,
    name    => $cli_package_name,
    require => Class['::sensu::repo'],
  }

  sensu_api_validator { 'sensu':
    sensu_api_server => $url_host,
    sensu_api_port   => $url_port,
    require          => Service['sensu-backend'],
    use_ssl          => $use_ssl,
  }
  # Ensure sensu-backend is up before starting sensu-agent
  Sensu_api_validator['sensu'] -> Service['sensu-agent']

  $sensuctl_configure = "sensuctl configure -n --url '${url}' --username 'admin' --password 'P@ssw0rd!'"
  $sensuctl_configure_creates = '/root/.config/sensu/sensuctl/cluster'
  exec { 'sensuctl_configure':
    command => "${sensuctl_configure} || rm -f ${sensuctl_configure_creates}",
    creates => $sensuctl_configure_creates,
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    require => Sensu_api_validator['sensu'],
  }

  package { 'sensu-go-backend':
    ensure  => $_version,
    name    => $package_name,
    before  => File['sensu_etc_dir'],
    require => Class['::sensu::repo'],
  }

  file { 'sensu_backend_state_dir':
    ensure  => 'directory',
    path    => $state_dir,
    owner   => $::sensu::user,
    group   => $::sensu::group,
    mode    => '0750',
    require => Package['sensu-go-backend'],
    before  => Service['sensu-backend'],
  }

  file { 'sensu_backend_config':
    ensure  => 'file',
    path    => "${etc_dir}/backend.yml",
    content => to_yaml($config),
    require => Package['sensu-go-backend'],
    notify  => Service['sensu-backend'],
  }

  service { 'sensu-backend':
    ensure => $service_ensure,
    enable => $service_enable,
    name   => $service_name,
    before => Service['sensu-agent'],
  }
}
