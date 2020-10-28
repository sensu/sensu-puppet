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
#   This parameter is mutually exclusive with ssl_ca_content
#
# @param ssl_ca_content
#   Content of SSL CA used by sensu services
#   This parameter is mutually exclusive with ssl_ca_source
#
# @param api_host
#   Sensu backend host used to configure sensuctl and verify API access.
# @param api_port
#   Sensu backend port used to configure sensuctl and verify API access.
# @param password
#   Sensu backend admin password used to confiure sensuctl.
# @param agent_password
#   The sensu agent password
# @param agent_entity_config_password
#   The password used when configuring Sensu Agent entity config items
#   Defaults to value used for `agent_password`.
# @param validate_namespaces
#   Determines if sensuctl and sensu_api types will validate their namespace exists
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
  Optional[String] $ssl_ca_source = $facts['puppet_localcacert'],
  Optional[String] $ssl_ca_content = undef,
  String $api_host = $trusted['certname'],
  Stdlib::Port $api_port = 8080,
  String $password = 'P@ssw0rd!',
  String $agent_password = 'P@ssw0rd!',
  Optional[String] $agent_entity_config_password = undef,
  Boolean $validate_namespaces = true,
) {

  if $ssl_ca_content {
    $_ssl_ca_source = undef
  } else {
    $_ssl_ca_source = $ssl_ca_source
  }
  if $use_ssl and !($_ssl_ca_source or $ssl_ca_content) {
    fail('sensu: ssl_ca_source or ssl_ca_content must be defined when use_ssl is true')
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
    $trusted_ca_file = $trusted_ca_file_path
  } else {
    $api_protocol = 'http'
    $trusted_ca_file = 'absent'
  }
  $api_url = "${api_protocol}://${api_host}:${api_port}"

  $_agent_entity_config_password = pick($agent_entity_config_password, $agent_password)

  case $facts['os']['family'] {
    'RedHat': {
      $os_package_require = []
    }
    'Debian': {
      $os_package_require = [Class['apt::update']]
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
    $package_require = [Class['sensu::repo']] + $os_package_require
  } else {
    $package_require = undef
  }

  include sensu::resources

}
