# = Define: sensu::plugin
#
# Installs the Sensu plugins
#
# == Parameters
#

define sensu::plugin(
  $type         = 'file',
  $install_path = '/etc/sensu/plugins',
  $purge        = true,
  $recurse      = true,
  $force        = true,
  $pkg_version  = 'latest',
){

  case $type {
    'file':       {
      $filename = inline_template("<%= scope.lookupvar('name').split('/').last %>")

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
