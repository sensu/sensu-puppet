# = Class: sensu::api
#
# Manages the Sensu api
#
# == Parameters
#
# [*hasrestart*]
#   Boolean. Value of hasrestart attribute for this service.
#   Default: true
#
class sensu::api (
  Boolean $hasrestart = $::sensu::hasrestart,
) {

  case $::osfamily {
    'Darwin': {
      $service_path     = '/Library/LaunchDaemons/org.sensuapp.sensu-api.plist'
      $service_provider = 'launchd'
    }
    default: {
      $service_path     = undef
      $service_provider = undef
    }
  }

  if $::sensu::manage_services {

    case $::sensu::api {
      true: {
        $service_ensure = 'running'
        $service_enable = true
      }
      default: {
        $service_ensure = 'stopped'
        $service_enable = false
      }
    }

    if $::osfamily != 'windows' {
      service { $::sensu::api_service_name:
        ensure     => $service_ensure,
        enable     => $service_enable,
        hasrestart => $hasrestart,
        path       => $service_path,
        provider   => $service_provider,
        subscribe  => [
          Class['sensu::package'],
          Sensu_api_config[$::fqdn],
          Class['sensu::redis::config'],
          Class['sensu::rabbitmq::config'],
        ],
      }
    }
  }

  if $::sensu::_purge_config and !$::sensu::server and !$::sensu::api and !$::sensu::enterprise {
    $file_ensure = 'absent'
  } else {
    $file_ensure = 'present'
  }

  file { "${sensu::etc_dir}/conf.d/api.json":
    ensure => $file_ensure,
    owner  => $::sensu::user,
    group  => $::sensu::group,
    mode   => $::sensu::file_mode,
  }

  sensu_api_config { $::fqdn:
    ensure                => $file_ensure,
    base_path             => "${sensu::etc_dir}/conf.d",
    bind                  => $::sensu::api_bind,
    host                  => $::sensu::api_host,
    port                  => $::sensu::api_port,
    user                  => $::sensu::api_user,
    password              => $::sensu::api_password,
    ssl_port              => $::sensu::api_ssl_port,
    ssl_keystore_file     => $::sensu::api_ssl_keystore_file,
    ssl_keystore_password => $::sensu::api_ssl_keystore_password,
  }
}
