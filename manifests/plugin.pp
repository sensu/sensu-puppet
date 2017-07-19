# = Define: sensu::plugin
#
# Installs the Sensu community script and plugins
# which can be used as monitoring checks
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
#   Default: undef (taken from $::sensu::sensu_plugin_provider)
#   Valid values: sensu_gem, apt, aptitude, yum
#
# [*nocheckcertificate*]
#   Boolean.  When using url source, disable certificate checking for HTTPS
#   Default: false
#   Valid values: true, false
#
# [*gem_install_options*]
#   Optional configuration to use for the installation of the
#   sensu plugin gem with sensu_gem provider.
#   See: https://docs.puppetlabs.com/references/latest/type.html#package-attribute-install_options
#   Default: $::sensu::gem_install_options
#   Example value: [{ '-p' => 'http://user:pass@myproxy.company.org:8080' }]
#
define sensu::plugin (
  Enum['file','url','package','directory'] $type                = 'file',
  String $install_path        = '/etc/sensu/plugins',
  Boolean $purge               = true,
  Boolean $recurse             = true,
  Boolean $force               = true,
  Pattern[/^absent$/,/^installed$/,/^latest$/,/^present$/,/^[\d\.\-]+$/] $pkg_version         = 'latest',
  Optional[String] $pkg_provider        = $::sensu::sensu_plugin_provider,
  Optional[String] $pkg_checksum        = undef,
  Boolean $nocheckcertificate  = false,
  Any $gem_install_options = $::sensu::gem_install_options,
) {

  File {
    owner => 'sensu',
    group => 'sensu',
  }

  Sensu::Plugin[$name]
  -> Class['sensu::client::service']

  case $type {
    'file': {
      $filename = basename($name)

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
    'url': {
      $filename = basename($name)

      sensu::plugins_dir { "${name}-${install_path}":
        path    => $install_path,
        purge   => $purge,
        recurse => $recurse,
        force   => $force,
      }

      remote_file { $name:
        ensure   => present,
        path     => "${install_path}/${filename}",
        source   => $name,
        checksum => $pkg_checksum,
        require  => File[$install_path],
      }

      file { "${install_path}/${filename}":
        ensure  => file,
        mode    => '0555',
        require => [
          File[$install_path],
          Remote_file[$name],
        ],
      }
    }
    'directory': {
      file { "${install_path}_for_plugin_${name}":
        ensure  => 'directory',
        path    => $install_path,
        mode    => '0555',
        source  => $name,
        recurse => $recurse,
        purge   => $purge,
        force   => $force,
        require => Package[$sensu::package::pkg_title],
      }
    }
    'package': {
      $gem_install_options_real = $pkg_provider ? {
        'gem'   => $gem_install_options,
        default => undef,
      }

      package { $name:
        ensure          => $pkg_version,
        provider        => $pkg_provider,
        install_options => $gem_install_options_real,
      }
    }
    default:      {
      fail('Unsupported sensu::plugin install type')
    }
  }
}
