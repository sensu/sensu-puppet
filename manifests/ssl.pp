# @summary Private class to manage sensu SSL resources
# @api private
#
class sensu::ssl {
  include sensu

  if $facts['os']['family'] == 'windows' {
    $directory_mode = undef
    $file_mode = undef
  } else {
    $directory_mode = '0700'
    $file_mode = '0644'
  }

  file { 'sensu_ssl_dir':
    ensure  => 'directory',
    path    => $sensu::ssl_dir,
    purge   => $sensu::ssl_dir_purge,
    recurse => $sensu::ssl_dir_purge,
    force   => $sensu::ssl_dir_purge,
    owner   => $sensu::sensu_user,
    group   => $sensu::sensu_group,
    mode    => $directory_mode,
  }

  file { 'sensu_ssl_ca':
    ensure    => 'file',
    path      => $sensu::trusted_ca_file_path,
    owner     => $sensu::sensu_user,
    group     => $sensu::sensu_group,
    mode      => $file_mode,
    show_diff => false,
    source    => $sensu::_ssl_ca_source,
    content   => $sensu::ssl_ca_content,
  }
}
