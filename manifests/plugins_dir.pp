# This is to verify the install_dir exists without duplicate declarations
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
