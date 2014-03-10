# = Define: sensu::plugin
#
# Installs the Sensu plugins
#
# == Parameters
#
# [*type*]
#   String.  Plugin source
#   Default: file
#   Valid values: file, directory, package
#
# [*install_path*]
#   String.  The path to install the plugin
#   Default: /etc/sensu/plugins
#
# [*purge*]
#   Boolean.  When using a directory source, purge setting
#   Default: true
#   Valid values: true, false
#
# [*recurse*]
#   Boolean.  When using a directory source, recurse setting
#   Default: true
#   Valid values: true, false
#
# [*force*]
#   Boolean.  When using a directory source, force setting
#   Default: true
#   Valid values: true, false
#
# [*pkg_version*]
#   String.  When using package source, version to install
#   Default: latest
#   Valid values: absent, installed, latest, present, [\d\.\-]+
#
define sensu::plugin(
  $type         = 'file',
  $install_path = '/etc/sensu/plugins',
  $purge        = true,
  $recurse      = true,
  $force        = true,
  $pkg_version  = 'latest',
){

  validate_bool($purge, $recurse, $force)
  validate_re($pkg_version, ['^absent$', '^installed$', '^latest$', '^present$', '^[\d\.\-]+$'], "Invalid package version: ${pkg_version}")

  case $type {
    'file':       {
      $filename = inline_template('<%= scope.lookupvar(\'name\').split(\'/\').last %>')

      file { "${install_path}/${filename}":
        ensure  => file,
        mode    => '0555',
        source  => $name,
      }
    }
    'directory':  {
      file { $install_path:
        ensure  => directory,
        mode    => '0555',
        source  => $name,
        recurse => $recurse,
        purge   => $purge,
        force   => $force,
      }
    }
    'package':    {
      package { $name:
        ensure  => $pkg_version
      }
    }
    default:      {
      fail('Unsupported sensu::plugin install type')
    }

  }
}
