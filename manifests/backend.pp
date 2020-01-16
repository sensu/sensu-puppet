# @summary Manage Sensu backend
#
# Class to manage the Sensu backend.
#
# @example
#   include sensu::backend
#
# @param version
#   Version of sensu backend to install.  Defaults to `installed` to support
#   Windows MSI packaging and to avoid surprising upgrades.
# @param package_name
#   Name of Sensu backend package.
# @param service_env_vars_file
#   Path to the backend service ENV variables file.
#   Debian based default: `/etc/default/sensu-backend`
#   RedHat based default: `/etc/sysconfig/sensu-backend`
# @param service_env_vars
#   Hash of environment variables loaded by sensu-backend service
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
# @param ssl_cert_source
#   The SSL certificate source
#   Do not define with ssl_cert_content
# @param ssl_cert_content
#   The SSL certificate content
#   Do not define with ssl_cert_source
# @param ssl_key_source
#   The SSL private key source
#   Do not define with ssl_key_content
# @param ssl_key_content
#   The SSL private key content
#   Do not define with ssl_key_content
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
# @param datastore
#   Datastore to configure for sensu events
# @param datastore_ensure
#   The datastore ensure property. If set to `absent` all
#   datastore parameters must still be defined.
# @param manage_postgresql_db
#   Boolean that sets of postgresql database should be managed
# @param postgresql_name
#   Name of PostgresConfig that is configured with sensuctl
# @param postgresql_user
#   The PostgreSQL database user
# @param postgresql_password
#   The PostgreSQL database password
# @param postgresql_host
#   The PostgreSQL host
# @param postgresql_port
#   The PostgreSQL port
# @param postgresql_dbname
#   The name of the PostgreSQL database
# @param postgresql_pool_size
#   The PostgreSQL pool size
#
class sensu::backend (
  Optional[String] $version = undef,
  String $package_name = 'sensu-go-backend',
  Optional[Stdlib::Absolutepath] $service_env_vars_file = undef,
  Hash $service_env_vars = {},
  String $service_name = 'sensu-backend',
  String $service_ensure = 'running',
  Boolean $service_enable = true,
  Stdlib::Absolutepath $state_dir = '/var/lib/sensu/sensu-backend',
  Hash $config_hash = {},
  Optional[String] $ssl_cert_source = undef,
  Optional[String] $ssl_cert_content = undef,
  Optional[String] $ssl_key_source = undef,
  Optional[String] $ssl_key_content = undef,
  Boolean $include_default_resources = true,
  Boolean $show_diff = true,
  Optional[String] $license_source = undef,
  Optional[String] $license_content = undef,
  Boolean $manage_tessen = true,
  Enum['present','absent'] $tessen_ensure = 'present',
  Optional[Enum['postgresql']] $datastore = undef,
  Enum['present','absent'] $datastore_ensure = 'present',
  Boolean $manage_postgresql_db = true,
  String $postgresql_name = 'postgresql',
  String $postgresql_user = 'sensu',
  String $postgresql_password = 'changeme',
  Stdlib::Host $postgresql_host = 'localhost',
  Stdlib::Port $postgresql_port = 5432,
  String $postgresql_dbname = 'sensu',
  Integer $postgresql_pool_size = 20,
) {

  if $license_source and $license_content {
    fail('sensu::backend: Do not define both license_source and license_content')
  }

  include sensu
  include sensu::common
  include sensu::cli
  include sensu::api
  if $datastore == 'postgresql' {
    include sensu::backend::datastore::postgresql
  }

  $etc_dir = $sensu::etc_dir
  $ssl_dir = $sensu::ssl_dir
  $use_ssl = $sensu::use_ssl
  $_version = pick($version, $sensu::version)
  $api_host = $sensu::api_host
  $api_port = $sensu::api_port
  $api_protocol = $sensu::api_protocol
  $password = $sensu::password

  if $use_ssl and $ssl_cert_source and $ssl_cert_content {
    fail('sensu::backend: Do not define both ssl_cert_source and ssl_cert_content_content')
  }
  if $use_ssl and ! ($ssl_cert_source and $ssl_cert_content) {
    $ssl_cert_source = $facts['puppet_hostcert']
  }
  if $use_ssl and $ssl_key_source and $ssl_key_content {
    fail('sensu::backend: Do not define both ssl_key_source and ssl_key_content')
  }
  if $use_ssl and ! ($ssl_key_source and $ssl_key_content) {
    $ssl_key_source = $facts['puppet_hostprivkey']
  }

  if $use_ssl {
    $trusted_ca_file = "${ssl_dir}/ca.crt"
    $ssl_config = {
      'cert-file'       => "${ssl_dir}/cert.pem",
      'key-file'        => "${ssl_dir}/key.pem",
      'trusted-ca-file' => $trusted_ca_file,
    }
    $service_subscribe = Class['sensu::ssl']
    Class['sensu::ssl'] -> Sensuctl_configure['puppet']
  } else {
    $trusted_ca_file = 'absent'
    $ssl_config = {}
    $service_subscribe = undef
  }

  $api_url = "${api_protocol}://${api_host}:${api_port}"
  $default_config = {
    'state-dir' => $state_dir,
    'api-url'   => $api_url,
  }
  $config = $default_config + $ssl_config + $config_hash
  $_service_env_vars = $service_env_vars.map |$key,$value| {
    "${key}=\"${value}\""
  }
  $_service_env_vars_lines = ['# This file is being maintained by Puppet.','# DO NOT EDIT'] + $_service_env_vars

  if $include_default_resources {
    include sensu::backend::default_resources
  }

  sensu_user { 'admin':
    ensure        => 'present',
    password      => $password,
    old_password  => $sensu::old_password,
    groups        => ['cluster-admins'],
    disabled      => false,
    configure     => true,
    configure_url => $api_url,
  }

  sensu_user { 'agent':
    ensure       => 'present',
    disabled     => false,
    password     => $sensu::agent_password,
    old_password => $sensu::agent_old_password,
    groups       => ['system:agents'],
  }

  if $manage_tessen {
    sensu_tessen { 'puppet': ensure => $tessen_ensure }
  }

  if $license_source or $license_content {
    file { 'sensu_license':
      ensure    => 'file',
      path      => "${etc_dir}/license.json",
      source    => $license_source,
      content   => $license_content,
      owner     => $sensu::user,
      group     => $sensu::group,
      mode      => '0600',
      show_diff => false,
      notify    => Exec['sensu-add-license'],
    }

    exec { 'sensu-add-license':
      path        => '/usr/bin:/bin:/usr/sbin:/sbin',
      command     => "sensuctl create --file ${etc_dir}/license.json",
      refreshonly => true,
      require     => Sensuctl_configure['puppet'],
    }
  }

  if $use_ssl {
    file { 'sensu_ssl_cert':
      ensure    => 'file',
      path      => "${ssl_dir}/cert.pem",
      source    => $ssl_cert_source,
      content   => $ssl_cert_content,
      owner     => $sensu::user,
      group     => $sensu::group,
      mode      => '0644',
      show_diff => false,
      notify    => Service['sensu-backend'],
    }
    file { 'sensu_ssl_key':
      ensure    => 'file',
      path      => "${ssl_dir}/key.pem",
      source    => $ssl_key_source,
      content   => $ssl_key_content,
      owner     => $sensu::user,
      group     => $sensu::group,
      mode      => '0600',
      show_diff => false,
      notify    => Service['sensu-backend'],
    }
  }

  package { 'sensu-go-backend':
    ensure  => $_version,
    name    => $package_name,
    before  => File['sensu_etc_dir'],
    require => $sensu::package_require,
  }

  file { 'sensu_backend_state_dir':
    ensure  => 'directory',
    path    => $state_dir,
    owner   => $sensu::user,
    group   => $sensu::group,
    mode    => '0750',
    require => Package['sensu-go-backend'],
    before  => Service['sensu-backend'],
  }

  file { 'sensu_backend_config':
    ensure    => 'file',
    path      => "${etc_dir}/backend.yml",
    content   => to_yaml($config),
    owner     => $sensu::user,
    group     => $sensu::group,
    mode      => '0640',
    show_diff => $show_diff,
    require   => Package['sensu-go-backend'],
    notify    => Service['sensu-backend'],
  }

  if $service_env_vars_file {
    $_service_env_vars_content = join($_service_env_vars_lines, "\n")
    file { 'sensu-backend_env_vars':
      ensure    => 'file',
      path      => $service_env_vars_file,
      content   => "${_service_env_vars_content}\n",
      owner     => $sensu::sensu_user,
      group     => $sensu::sensu_group,
      mode      => '0640',
      show_diff => $show_diff,
      require   => Package['sensu-go-backend'],
      notify    => Service['sensu-backend'],
    }
  }

  service { 'sensu-backend':
    ensure    => $service_ensure,
    enable    => $service_enable,
    name      => $service_name,
    subscribe => $service_subscribe,
  }
}
