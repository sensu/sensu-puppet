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
# @param license_source
#   The source of sensu-go enterprise license.
#   Supports any valid Puppet File sources such as absolute paths or puppet:///
#   Do not define with license_content
# @param license_content
#   The content of sensu-go enterprise license
#   Do not define with license_source
# @param manage_tessen
#   Boolean that determines if Tessen is managed
# @param tessen_ensure
#   Determine if Tessen is opt-in (present) or opt-out (absent)
# @param ad_auths
#   Hash of sensu_ad_auth resources
# @param assets
#   Hash of sensu_asset resources
# @param checks
#   Hash of sensu_check resources
# @param cluster_members
#   Hash of sensu_cluster_member resources
# @param cluster_role_bindings
#   Hash of sensu_cluster_role_binding resources
# @param cluster_roles
#   Hash of sensu_cluster_role resources
# @param configs
#   Hash of sensu_config resources
# @param entities
#   Hash of sensu_entitie resources
# @param events
#   Hash of sensu_event resources
# @param filters
#   Hash of sensu_filter resources
# @param handlers
#   Hash of sensu_handler resources
# @param hooks
#   Hash of sensu_hook resources
# @param ldap_auths
#   Hash of sensu_ldap_auth resources
# @param mutators
#   Hash of sensu_mutator resources
# @param namespaces
#   Hash of sensu_namespace resources
# @param role_bindings
#   Hash of sensu_role_binding resources
# @param roles
#   Hash of sensu_role resources
# @param silencings
#   Hash of sensu_silenced resources
# @param users
#   Hash of sensu_user resources
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
  Optional[String] $ssl_cert_source = $facts['puppet_hostcert'],
  Optional[String] $ssl_key_source = $facts['puppet_hostprivkey'],
  String $password = 'P@ssw0rd!',
  Optional[String] $old_password = undef,
  String $agent_password = 'P@ssw0rd!',
  Optional[String] $agent_old_password = undef,
  Boolean $include_default_resources = true,
  Boolean $show_diff = true,
  Optional[String] $license_source = undef,
  Optional[String] $license_content = undef,
  Boolean $manage_tessen = true,
  Enum['present','absent'] $tessen_ensure = 'present',
  Hash $ad_auths = {},
  Hash $assets = {},
  Hash $checks = {},
  Hash $cluster_members = {},
  Hash $cluster_role_bindings = {},
  Hash $cluster_roles = {},
  Hash $configs = {},
  Hash $entities = {},
  Hash $events = {},
  Hash $filters = {},
  Hash $handlers = {},
  Hash $hooks = {},
  Hash $ldap_auths = {},
  Hash $mutators = {},
  Hash $namespaces = {},
  Hash $role_bindings = {},
  Hash $roles = {},
  Hash $silencings = {},
  Hash $users = {},
) {

  if $license_source and $license_content {
    fail('sensu::backend: Do not define both license_source and license_content')
  }

  include ::sensu
  include ::sensu::backend::resources
  if $manage_tessen {
    include ::sensu::backend::tessen
  }

  $etc_dir = $::sensu::etc_dir
  $ssl_dir = $::sensu::ssl_dir
  $use_ssl = $::sensu::use_ssl
  $_version = pick($version, $::sensu::version)

  if $use_ssl and ! $ssl_cert_source {
    fail('sensu::backend: ssl_cert_source must be defined when sensu::use_ssl is true')
  }
  if $use_ssl and ! $ssl_key_source {
    fail('sensu::backend: ssl_key_source must be defined when sensu::use_ssl is true')
  }

  if $use_ssl {
    $url_protocol = 'https'
    $trusted_ca_file = "${ssl_dir}/ca.crt"
    $ssl_config = {
      'cert-file'       => "${ssl_dir}/cert.pem",
      'key-file'        => "${ssl_dir}/key.pem",
      'trusted-ca-file' => $trusted_ca_file,
    }
    $service_subscribe = Class['::sensu::ssl']
    Class['::sensu::ssl'] -> Sensu_configure['puppet']
  } else {
    $url_protocol = 'http'
    $trusted_ca_file = 'absent'
    $ssl_config = {}
    $service_subscribe = undef
  }

  $url = "${url_protocol}://${url_host}:${url_port}"
  $default_config = {
    'state-dir' => $state_dir,
    'api-url'   => $url,
  }
  $config = $default_config + $ssl_config + $config_hash


  if $include_default_resources {
    include ::sensu::backend::default_resources
  }

  package { 'sensu-go-cli':
    ensure  => $_version,
    name    => $cli_package_name,
    require => $::sensu::package_require,
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
    trusted_ca_file    => $trusted_ca_file,
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

  if $license_source or $license_content {
    file { 'sensu_license':
      ensure    => 'file',
      path      => "${etc_dir}/license.json",
      source    => $license_source,
      content   => $license_content,
      owner     => $::sensu::user,
      group     => $::sensu::group,
      mode      => '0600',
      show_diff => false,
      notify    => Exec['sensu-add-license'],
    }

    exec { 'sensu-add-license':
      path        => '/usr/bin:/bin:/usr/sbin:/sbin',
      command     => "sensuctl create --file ${etc_dir}/license.json",
      refreshonly => true,
      require     => Sensu_configure['puppet'],
    }
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
  }

  package { 'sensu-go-backend':
    ensure  => $_version,
    name    => $package_name,
    before  => File['sensu_etc_dir'],
    require => $::sensu::package_require,
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
    owner     => $::sensu::user,
    group     => $::sensu::group,
    mode      => '0640',
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
