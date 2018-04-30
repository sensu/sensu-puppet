class sensu::backend (
  Optional[String] $version = undef,
  String $package_name = 'sensu-backend',
  String $cli_package_name = 'sensu-cli',
  String $service_name = 'sensu-backend',
  String $service_ensure = 'running',
  Boolean $service_enable = true,
  Hash $config_hash = {},
  String $url = 'http://127.0.0.1:8080',
  String $username = 'admin',
  String $password = 'P@ssw0rd!',
) {

  include ::sensu

  $etc_dir = $::sensu::etc_dir

  if $version == undef {
    $_version = $::sensu::version
  } else {
    $_version = $version
  }

  package { 'sensu-cli':
    ensure => $_version,
    name   => $cli_package_name,
  }

  sensu_api_validator { 'sensu':
    sensu_api_server => '127.0.0.1',
    sensu_api_port   => '8080',
    require          => Service['sensu-backend'],
  }

  exec { 'sensuctl_configure':
    command => "sensuctl configure -n --url '${url}' --username '${username}' --password '${password}'",
    creates => '/root/.config/sensu/sensuctl/cluster',
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    require => Sensu_api_validator['sensu'],
  }

  package { 'sensu-backend':
    ensure => $_version,
    name   => $package_name,
    before => File['sensu_etc_dir'],
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
