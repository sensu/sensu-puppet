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
# @param ssl_cert_source
#   The SSL certificate source
# @param ssl_key_source
#   The SSL private key source
# @param ssl_add_ca_trust
#   Boolean that determines if SSL CA should be added
#   to the system's trust store
# @param password
#   Sensu backend admin password used to confiure sensuctl.
# @param old_password
#   Sensu backend admin old password needed when changing password.
# @param agent_password
#   The sensu agent password
# @param agent_old_password
#   The sensu agent old password needed when changing agent_password
# @param include_default_resources
#   Sets if default sensu resources should be included
# @param show_diff
#   Sets show_diff parameter for backend.yml configuration file
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
  String $url_host = $trusted['certname'],
  Stdlib::Port $url_port = 8080,
  String $ssl_cert_source = $facts['puppet_hostcert'],
  String $ssl_key_source = $facts['puppet_hostprivkey'],
  Boolean $ssl_add_ca_trust = true,
  String $password = 'P@ssw0rd!',
  Optional[String] $old_password = undef,
  String $agent_password = 'P@ssw0rd!',
  Optional[String] $agent_old_password = undef,
  Boolean $include_default_resources = true,
  Boolean $show_diff = true,
) {

  include ::sensu

  $etc_dir = $::sensu::etc_dir
  $ssl_dir = $::sensu::ssl_dir
  $use_ssl = $::sensu::use_ssl
  $_version = pick($version, $::sensu::version)

  if $use_ssl {
    $url_protocol = 'https'
    $ssl_config = {
      'cert-file'       => "${ssl_dir}/cert.pem",
      'key-file'        => "${ssl_dir}/key.pem",
      'trusted-ca-file' => "${ssl_dir}/ca.crt",
    }
    $service_subscribe = Class['::sensu::ssl']
    Class['::sensu::ssl'] -> Sensu_configure['puppet']
  } else {
    $url_protocol = 'http'
    $ssl_config = {}
    $service_subscribe = undef
  }

  $default_config = {
    'state-dir' => $state_dir,
  }
  $config = $default_config + $ssl_config + $config_hash

  $url = "${url_protocol}://${url_host}:${url_port}"

  if $include_default_resources {
    include ::sensu::backend::resources
  }

  package { 'sensu-go-cli':
    ensure  => $_version,
    name    => $cli_package_name,
    require => Class['::sensu::repo'],
  }

  sensu_api_validator { 'sensu':
    sensu_api_server => $url_host,
    sensu_api_port   => $url_port,
    use_ssl          => $use_ssl,
    require          => Service['sensu-backend'],
  }

  sensu_configure { 'puppet':
    url                => $url,
    username           => 'admin',
    password           => $password,
    bootstrap_password => 'P@ssw0rd!',
  }
  sensu_user { 'admin':
    ensure        => 'present',
    password      => $password,
    old_password  => $old_password,
    groups        => ['cluster-admins'],
    disabled      => false,
    configure     => true,
    configure_url => $url,
  }

  if $use_ssl {
    file { 'sensu_ssl_cert':
      ensure    => 'file',
      path      => "${ssl_dir}/cert.pem",
      source    => $ssl_cert_source,
      owner     => $::sensu::user,
      group     => $::sensu::group,
      mode      => '0644',
      show_diff => false,
      notify    => Service['sensu-backend'],
    }
    file { 'sensu_ssl_key':
      ensure    => 'file',
      path      => "${ssl_dir}/key.pem",
      source    => $ssl_key_source,
      owner     => $::sensu::user,
      group     => $::sensu::group,
      mode      => '0600',
      show_diff => false,
      notify    => Service['sensu-backend'],
    }
    # Needed for sensuctl
    if $ssl_add_ca_trust {
      ensure_packages(['openssl'])
      include ::trusted_ca
      trusted_ca::ca { 'sensu-ca':
        source  => "${::sensu::ssl_dir}/ca.crt",
        require => [
          Package['openssl'],
          File['sensu_ssl_ca'],
        ],
        before  => Sensu_configure['puppet'],
      }
    }
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
    ensure    => 'file',
    path      => "${etc_dir}/backend.yml",
    content   => to_yaml($config),
    show_diff => $show_diff,
    require   => Package['sensu-go-backend'],
    notify    => Service['sensu-backend'],
  }

  service { 'sensu-backend':
    ensure    => $service_ensure,
    enable    => $service_enable,
    name      => $service_name,
    subscribe => $service_subscribe,
  }
}
