# @summary Verifies if install_dir exists without duplicate declarations
#
# This define verifies if install_dir exists without duplicate declarations
#
# @param force Value of the parameter force of file resource for the
#   managed directory.
# @param purge Value of the parameter purge of file resource for the
#   managed directory.
# @param recurse Value of the parameter recurse of file resource for the
#   managed directory.
# @param path Path of the directory to create. If not defined the $title is used
#
define sensu::plugins_dir (
  Boolean $force,
  Boolean $purge,
  Boolean $recurse,
  String $path = $name,
) {
  if ! defined(File[$path]) {
    file { $path:
      ensure  => directory,
      mode    => '0555',
      owner   => 'sensu',
      group   => 'sensu',
      recurse => $recurse,
      purge   => $purge,
      force   => $force,
      require => Package[$sensu::package::pkg_title],
    }
  }
}
