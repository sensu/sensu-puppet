# @summary Sensu class for common resources
# @api private
#
class sensu::common {
  include sensu

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

  if $sensu::manage_user and $sensu::sensu_user {
    user { 'sensu':
      ensure     => 'present',
      name       => $sensu::sensu_user,
      forcelocal => true,
      shell      => '/bin/false',
      gid        => $sensu::sensu_group,
      uid        => undef,
      home       => '/var/lib/sensu',
      managehome => false,
      system     => true,
    }
  }
  if $sensu::manage_group and $sensu::sensu_group {
    group { 'sensu':
      ensure     => 'present',
      name       => $sensu::sensu_group,
      forcelocal => true,
      gid        => undef,
      system     => true,
    }
  }

  if $sensu::manage_repo {
    include sensu::repo
  }
}
