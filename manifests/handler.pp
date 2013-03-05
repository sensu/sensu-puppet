# = Define: sensu::handler
#
# Defines Sensu handlers
#
# == Parameters
#

define sensu::handler(
  $source       = '',
  $type         = 'pipe',
  $handlers     = [],
  $install_path = '/etc/sensu/handlers',
  $config       = '',
  $config_key   = '',
  $ensure       = 'present',
  $severities   = ['ok', 'warning', 'critical', 'unknown']
) {

  if defined(Class['sensu::service::server']) {
    $notify_services = Class['sensu::service::server']
  } else {
    $notify_services = []
  }

  $filename = inline_template("<%= scope.lookupvar('source').split('/').last %>")

  $real_key = $config_key ? {
    ''      => inline_template("<%= File.basename(scope.lookupvar('filename')).split('.').first %>"),
    default => $config_key
  }

  if $handlers != [] {
    sensu_handler { $name:
      ensure      => $ensure,
      type        => $type,
      handlers    => $handlers,
      severities  => $severities,
      notify      => $notify_services,
    }
  } else {
    $file_ensure = $ensure ? {
      'absent'  => 'abasent',
      default   => 'file'
    }

    file { "${install_path}/${filename}":
      ensure  => $file_file,
      owner   => 'sensu',
      group   => 'sensu',
      mode    => '0555',
      source  => $source,
    }

    sensu_handler { $real_key:
      ensure      => $ensure,
      type        => $type,
      command     => "${install_path}/${filename}",
      severities  => $severities,
      notify      => $notify_services,
    }
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

  sensu_handler_config { $real_key:
    ensure  => $config_present,
    config  => $config,
  }

}
