# @summary Sensu class for common resources
# @api private
#
class sensu::common {
  include sensu
  contain sensu::common::user

  if $sensu::etc_parent_dir {
    file { 'sensu_dir':
      ensure => 'directory',
      path   => $sensu::etc_parent_dir,
      owner  => $sensu::sensu_user,
      group  => $sensu::sensu_group,
      mode   => $sensu::directory_mode,
    }
  }

  file { 'sensu_etc_dir':
    ensure  => 'directory',
    path    => $sensu::etc_dir,
    owner   => $sensu::sensu_user,
    group   => $sensu::sensu_group,
    mode    => $sensu::directory_mode,
    purge   => $sensu::etc_dir_purge,
    recurse => $sensu::etc_dir_purge,
    force   => $sensu::etc_dir_purge,
  }

  if $sensu::use_ssl {
    contain sensu::ssl
  }

  if $sensu::manage_repo {
    include sensu::repo
  }
}
