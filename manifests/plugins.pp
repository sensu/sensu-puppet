# @summary Manage Sensu plugins
#
# Class to manage the Sensu plugins.
#
# @example
#   class { 'sensu::plugins':
#     plugins    => ['disk-checks'],
#     extensions => ['graphite'],
#   }
#
# @example
#   class { 'sensu::plugins':
#     plugins    => {
#       'disk-checks' => { 'version' => 'latest' },
#     },
#     extensions => {
#       'graphite' => { 'version' => 'latest' },
#     },
#   }
#
# @param manage_repo
#   Determines if plugin repo should be managed.
#   Defaults to value for `sensu::manage_repo`.
# @param package_ensure
#   Ensure property for sensu plugins package.
# @param package_name
#   Name of the Sensu plugins ruby package.
# @param dependencies
#   Package dependencies needed to install plugins and extensions.
#   Default is OS dependent.
# @param gem_dependencies
#   Gem dependencies.
# @param plugins
#   Plugins to install
# @param extensions
#   Extensions to install
#
class sensu::plugins (
  Optional[Boolean] $manage_repo = undef,
  String $package_ensure = 'installed',
  String $package_name = 'sensu-plugins-ruby',
  Array $dependencies = [],
  Array $gem_dependencies = [],
  Variant[Array, Hash] $plugins = [],
  Variant[Array, Hash] $extensions = [],
) {

  if $facts['os']['family'] == 'windows' {
    fail('sensu::plugins is not supported on Windows')
  }

  include sensu
  include sensu::common

  $_manage_repo = pick($manage_repo, $sensu::manage_repo)

  if $_manage_repo {
    include sensu::repo::community
    $package_require = [Class['sensu::repo::community']] + $sensu::os_package_require
  } else {
    $package_require = undef
  }

  package { 'sensu-plugins-ruby':
    ensure  => $package_ensure,
    name    => $package_name,
    require => $package_require,
  }

  ensure_packages($dependencies)
  $dependencies.each |$package| {
    Package[$package] -> Sensu_plugin <| |> # lint:ignore:spaceship_operator_without_tag
  }
  ensure_packages($gem_dependencies, {'provider' => 'sensu_gem', 'require' => [Package[$dependencies],Package['sensu-plugins-ruby']]})

  if $plugins =~ Array {
    $plugins.each |$plugin| {
      sensu_plugin { $plugin:
        ensure => 'present',
      }
    }
  } else {
    $plugins.each |$plugin, $plugin_data| {
      $data = { 'ensure' => 'present' } + $plugin_data
      sensu_plugin { $plugin:
        * => $data,
      }
    }
  }

  if $extensions =~ Array {
    $extensions.each |$extension| {
      sensu_plugin { $extension:
        ensure    => 'present',
        extension => true,
      }
    }
  } else {
    $extensions.each |$extension, $extension_data| {
      $data = { 'ensure' => 'present', 'extension' => true } + $extension_data
      sensu_plugin { $extension:
        * => $data,
      }
    }
  }

}
