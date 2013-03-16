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
  # Used to install the handler
  $source       = '',
  $install_path = '/etc/sensu/handlers',
  # Handler specific config
  $config       = '',
  $config_key   = $name,
  $purge_config = $sensu::purge_config,
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

  # Handler config
  case $ensure {
    'present': {
      $config_present = $config ? {
        ''      => 'absent',
        default => 'present'
      }
    }
    default: {
      $config_present = 'absent'
    }
  }

  if $purge_config {
    file { "/etc/sensu/conf.d/handler_${name}.json": ensure => $ensure, before => Sensu_handler[$name] }
    file { "/etc/sensu/conf.d/${config_key}.json": ensure => $config_present, before => Sensu_handler_config[$config_key] }
  }

  sensu_handler { $name:
    ensure      => $ensure,
    type        => $type,
    command     => $command_real,
    handlers    => $handlers,
    severities  => $severities,
    exchange    => $exchange,
    mutator     => $mutator,
    notify      => $notify_services,
  }

  sensu_handler_config { $config_key:
    ensure  => $config_present,
    config  => $config,
  }

}
