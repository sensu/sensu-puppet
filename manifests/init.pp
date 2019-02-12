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
# @param user
#   User used by sensu services
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
#
class sensu (
  String $version = 'installed',
  Stdlib::Absolutepath $etc_dir = '/etc/sensu',
  Stdlib::Absolutepath $ssl_dir = '/etc/sensu/ssl',
  String $user = 'sensu',
  String $group = 'sensu',
  Boolean $etc_dir_purge = true,
  Boolean $ssl_dir_purge = true,
  Boolean $manage_repo = true,
  Boolean $use_ssl = true,
  String $ssl_ca_source = $facts['puppet_localcacert'],
) {

  if $manage_repo {
    include ::sensu::repo
    $package_require = Class['::sensu::repo']
  } else {
    $package_require = undef
  }

  file { 'sensu_etc_dir':
    ensure  => 'directory',
    path    => $etc_dir,
    purge   => $etc_dir_purge,
    recurse => $etc_dir_purge,
    force   => $etc_dir_purge,
  }

  if $use_ssl {
    contain ::sensu::ssl
  }

  case $facts['os']['family'] {
    'RedHat': {
    }
    'Debian': {
    }
    default: {
      fail("Detected osfamily <${::osfamily}>. Only RedHat and Debian are supported.")
    }
  }
}
