# = Define: sensu::plugin
#
# Installs the Sensu plugins
#
# == Parameters
#
# [*type*]
#   String.  Plugin source
#   Default: file
#   Valid values: file, directory, package, url
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
# [*pkg_provider*]
#   String.  When using package to install plugins, provider to use.
#   Default: undef
#   Valid values: aptitude, apt, sensu_gem
#
# [*nocheckcertificate*]
#   Boolean.  When using url source, disable certificate checking for HTTPS
#   Default: false
#   Valid values: true, false
define sensu::plugin(
  $type               = 'file',
  $install_path       = '/etc/sensu/plugins',
  $purge              = true,
  $recurse            = true,
  $force              = true,
  $pkg_version        = 'latest',
  $pkg_provider       = $::sensu::sensu_plugin_provider,
  $pkg_checksum       = undef,
  $nocheckcertificate = false,
){

  File {
    owner => 'sensu',
    group => 'sensu',
  }

  Sensu::Plugin[$name] ->
  Class['sensu::client::service']

  validate_bool($purge, $recurse, $force, $nocheckcertificate)
  validate_re($pkg_version, ['^absent$', '^installed$', '^latest$', '^present$', '^[\d\.\-]+$'], "Invalid package version: ${pkg_version}")
  validate_re($type, ['^file$', '^url$', '^package$', '^directory$'], "Invalid plugin type: ${type}")

  case $type {
    'file':       {
      $filename = inline_template('<%= scope.lookupvar(\'name\').split(\'/\').last %>')

      sensu::plugins_dir { "${name}-${install_path}":
        path    => $install_path,
        purge   => $purge,
        recurse => $recurse,
        force   => $force,
      }

      file { "${install_path}/${filename}":
        ensure  => file,
        mode    => '0555',
        source  => $name,
        require => File[$install_path],
      }
    }
    'url' : {
        $filename = inline_template('<%= scope.lookupvar(\'name\').split(\'/\').last %>')

        sensu::plugins_dir { "${name}-${install_path}":
          path    => $install_path,
          purge   => $purge,
          recurse => $recurse,
          force   => $force,
        }

        validate_string($pkg_checksum)

        remote_file { $name:
          ensure   => present,
          path     => "${install_path}/${filename}",
          checksum => $pkg_checksum,
          require  => File[$install_path],
        } ->
        file { "${install_path}/${filename}":
          ensure  => file,
          mode    => '0555',
          require => File[$install_path],
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
        require => Package['sensu'],
      }
    }
    'package':    {
      package { $name:
        ensure   => $pkg_version,
        provider => $pkg_provider,
      }
    }
    default:      {
      fail('Unsupported sensu::plugin install type')
    }

  }
}
