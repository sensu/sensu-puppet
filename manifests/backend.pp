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
) {

  include ::sensu

  $etc_dir = $::sensu::etc_dir

  $url = "http://${url_host}:${url_port}"

  if $version == undef {
    $_version = $::sensu::version
  } else {
    $_version = $version
  }

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

  $sensuctl_configure = "sensuctl configure -n --url '${url}' --username '${username}' --password '${password}'"
  $sensuctl_configure_creates = '/root/.config/sensu/sensuctl/cluster'
  exec { 'sensuctl_configure':
    command => "${sensuctl_configure} || rm -f ${sensuctl_configure_creates}",
    creates => $sensuctl_configure_creates,
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    require => Sensu_api_validator['sensu'],
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
