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
# @param service_path
#   The path to sensu-backend service executable
# @param state_dir
#   Sensu backend state directory path.
# @param config_hash
#   Sensu backend configuration hash used to define backend.yml.
# @param ssl_cert_source
#   The SSL certificate source
#   This parameter is mutually exclusive with ssl_cert_content
# @param ssl_cert_content
#   The SSL certificate content
#   This parameter is mutually exclusive with ssl_cert_source
# @param ssl_key_source
#   The SSL private key source
#   This parameter is mutually exclusive with ssl_key_content
# @param ssl_key_content
#   The SSL private key content
#   This parameter is mutually exclusive with ssl_key_source
# @param include_default_resources
#   Sets if default sensu resources should be included
# @param include_agent_resources
#   Sets if agent RBAC resources should be included
# @param manage_agent_user
#   Sets if the Sensu agent user should be managed
# @param agent_user_disabled
#   Sets if the Sensu agent user should be disabled
#   Not applicable if `manage_agent_user` is `false`
#   This is useful if using agent TLS authentication
#   See https://docs.sensu.io/sensu-go/latest/guides/securing-sensu/#sensu-agent-tls-authentication
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
# @param postgresql_sslmode
#   The PostgreSQL sslmode value
# @param postgresql_ssl_dir
#   The path to store SSL related files for PostgreSQL connections
# @param postgresql_ssl_ca_source
#   The source of PostgreSQL SSL CA
#   Do not define with postgresql_ssl_ca_content
# @param postgresql_ssl_ca_content
#   The content of PostgreSQL SSL CA
#   Do not define with postgresql_ssl_ca_source
# @param postgresql_ssl_crl_source
#   The source of PostgreSQL SSL CRL
#   Do not define with postgresql_ssl_crl_content
# @param postgresql_ssl_crl_content
#   The content of PostgreSQL SSL CRL
#   Do not define with postgresql_ssl_crl_source
# @param postgresql_ssl_cert_source
#   The source of PostgreSQL SSL certificate
#   Do not define with postgresql_ssl_cert_content
# @param postgresql_ssl_cert_content
#   The content of PostgreSQL SSL certificate
#   Do not define with postgresql_ssl_cert_source
# @param postgresql_ssl_key_source
#   The source of PostgreSQL SSL private key
#   Do not define with postgresql_ssl_key_content
# @param postgresql_ssl_key_content
#   The content of PostgreSQL SSL private key
#   Do not define with postgresql_ssl_key_source
# @param postgresql_pool_size
#   The PostgreSQL pool size
# @param postgresql_strict
#   Enables strict configuration checks for PostgreSQL
# @param postgresql_batch_buffer
#   PostgreSQL batch buffer size
# @param postgresql_batch_size
#   PostgreSQL batch size
# @param postgresql_batch_workers
#   PostgreSQL batch workers
#
class sensu::backend (
  Optional[String] $version = undef,
  String $package_name = 'sensu-go-backend',
  Optional[Stdlib::Absolutepath] $service_env_vars_file = undef,
  Hash $service_env_vars = {},
  String $service_name = 'sensu-backend',
  String $service_ensure = 'running',
  Boolean $service_enable = true,
  Stdlib::Absolutepath $service_path = '/usr/sbin/sensu-backend',
  Stdlib::Absolutepath $state_dir = '/var/lib/sensu/sensu-backend',
  Hash $config_hash = {},
  Optional[String] $ssl_cert_source = $facts['puppet_hostcert'],
  Optional[String] $ssl_cert_content = undef,
  Optional[String] $ssl_key_source = $facts['puppet_hostprivkey'],
  Optional[String] $ssl_key_content = undef,
  Boolean $include_default_resources = true,
  Boolean $include_agent_resources = true,
  Boolean $manage_agent_user = true,
  Boolean $agent_user_disabled = false,
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
  Enum['disable','require','verify-ca','verify-full'] $postgresql_sslmode = 'require',
  Stdlib::Absolutepath $postgresql_ssl_dir = '/var/lib/sensu/.postgresql',
  Optional[String] $postgresql_ssl_ca_source = undef,
  Optional[String] $postgresql_ssl_ca_content = undef,
  Optional[String] $postgresql_ssl_crl_source = undef,
  Optional[String] $postgresql_ssl_crl_content = undef,
  Optional[String] $postgresql_ssl_cert_source = undef,
  Optional[String] $postgresql_ssl_cert_content = undef,
  Optional[String] $postgresql_ssl_key_source = undef,
  Optional[String] $postgresql_ssl_key_content = undef,
  Integer $postgresql_pool_size = 20,
  Boolean $postgresql_strict = false,
  Integer $postgresql_batch_buffer = 0,
  Integer $postgresql_batch_size = 1,
  Integer $postgresql_batch_workers = 20,
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

  $_version = pick($version, $sensu::version)

  if $ssl_cert_content {
    $_ssl_cert_source = undef
  } else {
    $_ssl_cert_source = $ssl_cert_source
  }
  if $ssl_key_content {
    $_ssl_key_source = undef
  } else {
    $_ssl_key_source = $ssl_key_source
  }

  if $sensu::use_ssl {
    if !($_ssl_cert_source or $ssl_cert_content) {
      fail('sensu::backend: ssl_cert_source or ssl_cert_content must be defined when sensu::use_ssl is true')
    }
    if !($_ssl_key_source or $ssl_key_content) {
      fail('sensu::backend: ssl_key_source or ssl_key_content must be defined when sensu::use_ssl is true')
    }
    $ssl_config = {
      'cert-file'       => "${sensu::ssl_dir}/cert.pem",
      'key-file'        => "${sensu::ssl_dir}/key.pem",
      'trusted-ca-file' => $sensu::trusted_ca_file_path,
    }
    $service_subscribe = Class['sensu::ssl']
    Class['sensu::ssl'] -> Sensuctl_configure['puppet']
  } else {
    $ssl_config = {}
    $service_subscribe = undef
  }

  $default_config = {
    'state-dir' => $state_dir,
    'api-url'   => $sensu::api_url,
  }
  $config = $default_config + $ssl_config + $config_hash
  $_service_env_vars = $service_env_vars.map |$key,$value| {
    "${key}=\"${value}\""
  }
  $_service_env_vars_lines = ['# This file is being maintained by Puppet.','# DO NOT EDIT'] + $_service_env_vars

  if $include_default_resources {
    include sensu::backend::default_resources
  }
  if $include_agent_resources {
    include sensu::backend::agent_resources
  }

  # See https://docs.sensu.io/sensu-go/latest/installation/upgrade/
  # Only necessary for Puppet < 6.1.0,
  # See https://github.com/puppetlabs/puppet/commit/f8d5c60ddb130c6429ff12736bfdb4ae669a9fd4
  if versioncmp($facts['puppetversion'],'6.1.0') < 0 and $facts['service_provider'] == 'systemd' {
    Package['sensu-go-backend'] ~> Class['systemd::systemctl::daemon_reload']
    Class['systemd::systemctl::daemon_reload'] -> Service['sensu-backend']
  }

  sensu_user { 'admin':
    ensure                    => 'present',
    password                  => $sensu::password,
    groups                    => ['cluster-admins'],
    disabled                  => false,
    configure                 => true,
    configure_url             => $sensu::api_url,
    configure_trusted_ca_file => $sensu::trusted_ca_file,
    provider                  => 'sensu_api',
    before                    => Sensuctl_configure['puppet'],
  }

  if $manage_agent_user {
    sensu_user { 'agent':
      ensure   => 'present',
      disabled => $agent_user_disabled,
      password => $sensu::agent_password,
      groups   => ['system:agents'],
    }
  }

  if $manage_tessen {
    sensu_tessen { 'puppet': ensure => $tessen_ensure }
  }

  if $license_source or $license_content {
    file { 'sensu_license':
      ensure    => 'file',
      path      => "${sensu::etc_dir}/license.json",
      source    => $license_source,
      content   => $license_content,
      owner     => $sensu::user,
      group     => $sensu::group,
      mode      => '0600',
      show_diff => false,
      notify    => Sensu_license['puppet'],
    }

    sensu_license { 'puppet':
      ensure => 'present',
      file   => "${sensu::etc_dir}/license.json",
    }
  }

  if $sensu::use_ssl {
    file { 'sensu_ssl_cert':
      ensure    => 'file',
      path      => "${sensu::ssl_dir}/cert.pem",
      source    => $_ssl_cert_source,
      content   => $ssl_cert_content,
      owner     => $sensu::user,
      group     => $sensu::group,
      mode      => '0644',
      show_diff => false,
      notify    => Service['sensu-backend'],
    }
    file { 'sensu_ssl_key':
      ensure    => 'file',
      path      => "${sensu::ssl_dir}/key.pem",
      source    => $_ssl_key_source,
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
    notify  => Service['sensu-backend'],
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
    path      => "${sensu::etc_dir}/backend.yml",
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

  if $facts['service_provider'] == 'systemd' {
    systemd::dropin_file { 'sensu-backend-start.conf':
      unit    => 'sensu-backend.service',
      content => join([
        '[Service]',
        'ExecStart=',
        "ExecStart=${service_path} start -c ${sensu::etc_dir}/backend.yml",
      ], "\n"),
      notify  => Service['sensu-backend'],
    }
  }

  service { 'sensu-backend':
    ensure    => $service_ensure,
    enable    => $service_enable,
    name      => $service_name,
    subscribe => $service_subscribe,
  }

  exec { 'sensu-backend init':
    path        => '/usr/bin:/bin:/usr/sbin:/sbin',
    environment => [
      'SENSU_BACKEND_CLUSTER_ADMIN_USERNAME=admin',
      "SENSU_BACKEND_CLUSTER_ADMIN_PASSWORD=${sensu::password}",
    ],
    returns     => [0, 3],
    # sensu-backend init will exit with code 3 if already run
    # If exit code is 3, do not need to run sensu-backend init again
    # If exit is not 3, run sensu-backend init
    unless      => 'sensu-backend init ; [ $? -eq 3 ] && exit 0 || exit 1',
    require     => Sensu_api_validator['sensu'],
    before      => [
      Sensu_user['admin'],
      Sensuctl_configure['puppet'],
    ],
  }
}
