# = Define: sensu::handler
#
# Defines Sensu handlers
#
# == Parameters
#

define sensu::handler(
  $type         = 'pipe',
  $command      = undef,
  $handlers     = undef,
  $ensure       = 'present',
  $severities   = ['ok', 'warning', 'critical', 'unknown'],
  $exchange     = undef,
  $mutator      = undef,
  $socket       = undef,
  # Used to install the handler
  $source       = '',
  $install_path = '/etc/sensu/handlers',
  # Handler specific config
  $config       = undef,
) {

  if defined(Class['sensu::service::server']) {
    $notify_services = Class['sensu::service::server']
  } else {
    $notify_services = []
  }

  if $source != '' {

    $filename = inline_template("<%= scope.lookupvar('source').split('/').last %>")
    $command_real = "${install_path}/${filename}"

    $file_ensure = $ensure ? {
      'absent'  => 'absent',
      default   => 'file'
    }

    file { $command_real:
      ensure  => $file_ensure,
      owner   => 'sensu',
      group   => 'sensu',
      mode    => '0555',
      source  => $source,
    }
  } else {
    $command_real = $command
  }

  file { "/etc/sensu/conf.d/handlers/${name}.json":
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0444',
    before  => Sensu_handler[$name],
  }

  sensu_handler { $name:
    ensure     => $ensure,
    type       => $type,
    command    => $command_real,
    handlers   => $handlers,
    severities => $severities,
    exchange   => $exchange,
    socket     => $socket,
    mutator    => $mutator,
    config     => $config,
    notify     => $notify_services,
    require    => File['/etc/sensu/conf.d/handlers'],
  }

}
