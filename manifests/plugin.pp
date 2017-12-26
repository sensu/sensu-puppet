# @summary Installs Sensu plugins
#
# Installs the Sensu community script and plugins
# which can be used as monitoring checks
#
# @param type Plugin source
#   Valid values: file, directory, package, url
#
# @param install_path The path to install the plugin
#
# @param purge When using a directory source, purge setting
#
# @param recurse When using a directory source, recurse setting
#
# @param force When using a directory source, force setting
#
# @param pkg_version When using package source, version to install
#
# @param pkg_provider When using package to install plugins, provider to use.
#   Valid values: sensu_gem, apt, aptitude, yum
#
# @param pkg_checksum The packake's MD5 checksum.
#   Valid values: Any valid MD5 string of the wanted package
#
# @param nocheckcertificate When using url source, disable certificate checking for HTTPS
#
# @param gem_install_options Optional configuration to use for the installation of the
#   sensu plugin gem with sensu_gem provider.
#   See: https://docs.puppetlabs.com/references/latest/type.html#package-attribute-install_options
#   Example value: [{ '-p' => 'http://user:pass@myproxy.company.org:8080' }]
#
define sensu::plugin (
  Enum['file','url','package','directory'] $type                = 'file',
  Stdlib::Absolutepath $install_path = $::osfamily ? {
    'windows' => 'C:/opt/sensu/plugins',
    default   => '/etc/sensu/plugins',
  },
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
  ~> Service['sensu-client']

  # (#463) All plugins must come before all checks.  Collections are not used to
  # avoid realizing any resources.
  Sensu::Plugin[$name]
  -> Anchor['plugins_before_checks']

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
