# @summary Installs the Sensu packages
#
# Installs Sensu enterprise
#
# @param deregister_handler The handler to use when deregistering a client on stop.
#
# @param deregister_on_stop Whether the sensu client should deregister from the API on service stop
#
# @param gem_path Paths to add to GEM_PATH if we need to look for different dirs.
#
# @param init_stop_max_wait Number of seconds to wait for the init stop script to run
#
# @param log_dir Sensu log directory to be used
#   Valid values: Any valid log directory path, accessible by the sensu user
#
# @param log_level Sensu log level to be used
#   Valid values: debug, info, warn, error, fatal
#
# @param path Used to set PATH in /etc/default/sensu
#
# @param rubyopt Ruby opts to be passed to the sensu services
#
# @param use_embedded_ruby If the embedded ruby should be used, e.g. to install the
#   sensu-plugin gem.  This value is overridden by a defined
#   sensu_plugin_provider.  Note, the embedded ruby should always be used to
#   provide full compatibility.  Using other ruby runtimes, e.g. the system
#   ruby, is not recommended.
#
# @param heap_size Value of the HEAP_SIZE environment variable.
#
# @param max_open_files Value of the MAX_OPEN_FILES environment variable.
#
class sensu::enterprise (
  Optional[String]  $deregister_handler = $::sensu::deregister_handler,
  Optional[Boolean] $deregister_on_stop = $::sensu::deregister_on_stop,
  Optional[String]  $gem_path           = $::sensu::gem_path,
  Variant[Undef,Integer,Pattern[/^(\d+)$/]] $init_stop_max_wait = $::sensu::init_stop_max_wait,
  Optional[String]  $log_dir            = $::sensu::log_dir,
  Optional[String]  $log_level          = $::sensu::log_level,
  Optional[String]  $path               = $::sensu::path,
  Optional[String]  $rubyopt            = $::sensu::rubyopt,
  Optional[Boolean] $use_embedded_ruby  = $::sensu::use_embedded_ruby,
  Variant[Undef,Integer,Pattern[/^(\d+)/]] $heap_size = $::sensu::heap_size,
  Variant[Undef,Integer,Pattern[/^(\d+)$/]] $max_open_files = $::sensu::max_open_files,
  Boolean $hasrestart                   = $::sensu::hasrestart,
  ){

  # Package
  if $::sensu::enterprise {

    package { 'sensu-enterprise':
      ensure  => $::sensu::enterprise_version,
    }

    file { '/etc/default/sensu-enterprise':
      ensure  => file,
      content => template("${module_name}/sensu.erb"),
      owner   => '0',
      group   => '0',
      mode    => '0444',
      require => Package['sensu-enterprise'],
    }
  }

  # Service
  if $::sensu::manage_services and $::sensu::enterprise {

    case $::sensu::enterprise {
      true: {
        $ensure = 'running'
        $enable = true
      }
      default: {
        $ensure = 'stopped'
        $enable = false
      }
    }

    if $::osfamily != 'windows' {
      service { 'sensu-enterprise':
        ensure     => $ensure,
        enable     => $enable,
        hasrestart => $hasrestart,
        subscribe  => [
          File['/etc/default/sensu-enterprise'],
          Sensu_api_config[$::fqdn],
          Class['sensu::redis::config'],
          Class['sensu::rabbitmq::config'],
        ],
      }
    }
  }
}
