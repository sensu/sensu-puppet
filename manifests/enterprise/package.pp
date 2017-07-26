# = Class: sensu::package
#
# Installs the Sensu packages
#
# == Parameters
#
# [*deregister_handler*]
#   String. The handler to use when deregistering a client on stop.
#   Default: $::sensu::deregister_handler
#
# [*deregister_on_stop*]
#   Boolean. Whether the sensu client should deregister from the API on service stop
#   Default: $::sensu::deregister_on_stop
#
# [*gem_path*]
#   String.  Paths to add to GEM_PATH if we need to look for different dirs.
#   Default: $::sensu::gem_path
#
# [*init_stop_max_wait*]
#   Integer.  Number of seconds to wait for the init stop script to run
#   Default: $::sensu::init_stop_max_wait
#
# [*log_dir*]
#   String.  Sensu log directory to be used
#   Default: $::sensu::log_dir
#   Valid values: Any valid log directory path, accessible by the sensu user
#
# [*log_level*]
#   String.  Sensu log level to be used
#   Default: $::sensu::log_level
#   Valid values: debug, info, warn, error, fatal
#
# [*path*]
#   String. Used to set PATH in /etc/default/sensu
#   Default: $::sensu::path
#
# [*rubyopt*]
#   String.  Ruby opts to be passed to the sensu services
#   Default: $::sensu::rubyopt
#
# [*use_embedded_ruby*]
#   Boolean.  If the embedded ruby should be used, e.g. to install the
#   sensu-plugin gem.  This value is overridden by a defined
#   sensu_plugin_provider.  Note, the embedded ruby should always be used to
#   provide full compatibility.  Using other ruby runtimes, e.g. the system
#   ruby, is not recommended.
#   Default: $::sensu::use_embedded_ruby
#   Valid values: true, false
#
# [*heap_size*]
#   String. Value of the HEAP_SIZE environment variable.
#   Default: $::sensu::heap_size
#
class sensu::enterprise::package (
  $deregister_handler = $::sensu::deregister_handler,
  $deregister_on_stop = $::sensu::deregister_on_stop,
  $gem_path           = $::sensu::gem_path,
  $init_stop_max_wait = $::sensu::init_stop_max_wait,
  $log_dir            = $::sensu::log_dir,
  $log_level          = $::sensu::log_level,
  $path               = $::sensu::path,
  $rubyopt            = $::sensu::rubyopt,
  $use_embedded_ruby  = $::sensu::use_embedded_ruby,
  $heap_size          = $::sensu::heap_size,
  ){

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

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
}
