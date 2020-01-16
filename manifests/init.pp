# @summary Base Sensu class
#
# This is the main Sensu class
#
# @param version
#   Version of Sensu to install.  Defaults to `installed` to support
#   Windows MSI packaging and to avoid surprising upgrades.
#
# @param etc_dir
#   Absolute path to the Sensu etc directory.
#
# @param ssl_dir
#   Absolute path to the Sensu ssl directory.
#
# @param manage_user
#   Boolean that determines if sensu user should be managed
#
# @param user
#   User used by sensu services
#
# @param manage_group
#   Boolean that determines if sensu group should be managed
#
# @param group
#   User group used by sensu services
#
# @param etc_dir_purge
#   Boolean to determine if the etc_dir should be purged
#   such that only Puppet managed files are present.
#
# @param ssl_dir_purge
#   Boolean to determine if the ssl_dir should be purged
#   such that only Puppet managed files are present.
#
# @param manage_repo
#   Boolean to determine if software repository for Sensu
#   should be managed.
#
# @param use_ssl
#   Sensu backend service uses SSL
#
# @param ssl_ca_source
#   Source of SSL CA used by sensu services
#   Do not define with ssl_ca_content
# @param ssl_ca_content
#   Content of SSL CA used by sensu services
#   Do not define with ssl_ca_source
#
# @param api_host
#   Sensu backend host used to configure sensuctl and verify API access.
# @param api_port
#   Sensu backend port used to configure sensuctl and verify API access.
# @param password
#   Sensu backend admin password used to confiure sensuctl.
# @param old_password
#   Sensu backend admin old password needed when changing password.
# @param agent_password
#   The sensu agent password
# @param agent_old_password
#   The sensu agent old password needed when changing agent_password
class sensu (
  String $version = 'installed',
  Stdlib::Absolutepath $etc_dir = '/etc/sensu',
  Stdlib::Absolutepath $ssl_dir = '/etc/sensu/ssl',
  Boolean $manage_user = true,
  String $user = 'sensu',
  Boolean $manage_group = true,
  String $group = 'sensu',
  Boolean $etc_dir_purge = true,
  Boolean $ssl_dir_purge = true,
  Boolean $manage_repo = true,
  Boolean $use_ssl = true,
  Optional[String] $ssl_ca_source = undef,
  Optional[String] $ssl_ca_content = undef,
  String $api_host = $trusted['certname'],
  Stdlib::Port $api_port = 8080,
  String $password = 'P@ssw0rd!',
  Optional[String] $old_password = undef,
  String $agent_password = 'P@ssw0rd!',
  Optional[String] $agent_old_password = undef,
) {

  if $use_ssl and $ssl_ca_source and $ssl_ca_content {
    fail('sensu::backend: Do not define both ssl_ca_source and ssl_ca_content_content')
  }
  if $use_ssl and ! ($ssl_ca_source or $ssl_ca_content) {
    $ssl_ca_source = $facts['puppet_localcacert']
  }

  if $facts['os']['family'] == 'windows' {
    # dirname can not handle back slashes so convert to forward slash then back to back slash
    $etc_dir_fixed = regsubst($etc_dir, '\\\\', '/', 'G')
    $etc_parent_dirname = dirname($etc_dir_fixed)
    $etc_parent_dir = regsubst($etc_parent_dirname, '/', '\\\\', 'G')
    $sensu_user = undef
    $sensu_group = undef
    $directory_mode = undef
    $file_mode = undef
    $trusted_ca_file_path = "${ssl_dir}\\ca.crt"
    $agent_config_path = "${etc_dir}\\agent.yml"
  } else {
    $etc_parent_dir = undef
    $sensu_user = $user
    $sensu_group = $group
    $directory_mode = '0755'
    $file_mode = '0640'
    $join_path = '/'
    $trusted_ca_file_path = "${ssl_dir}/ca.crt"
    $agent_config_path = "${etc_dir}/agent.yml"
  }

  if $use_ssl {
    $api_protocol = 'https'
  } else {
    $api_protocol = 'http'
  }
  $api_url = "${api_protocol}://${api_host}:${api_port}"

  case $facts['os']['family'] {
    'RedHat': {
      $os_package_require = []
    }
    'Debian': {
      $os_package_require = [Class['::apt::update']]
    }
    'windows': {
      $os_package_require = []
    }
    default: {
      fail("Detected osfamily <${facts['os']['family']}>. Only RedHat, Debian and Windows are supported.")
    }
  }

  # $package_require is used by sensu::agent and sensu::backend
  # package resources
  if $manage_repo {
    $package_require = [Class['::sensu::repo']] + $os_package_require
  } else {
    $package_require = undef
  }

  include sensu::resources
}
