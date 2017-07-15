# = Class: sensu::package
#
# Installs the Sensu packages
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
