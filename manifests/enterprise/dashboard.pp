# @summary Installs the Sensu Enterprise Dashboard
#
# Installs the Sensu Enterprise Dashboard
class sensu::enterprise::dashboard (
  Boolean $hasrestart = $::sensu::hasrestart,
) {

  # Package
  if $::sensu::enterprise_dashboard {
    package { 'sensu-enterprise-dashboard':
      ensure => $::sensu::enterprise_dashboard_version,
    }
  }

  # Config
  if $::sensu::enterprise_dashboard {
    $ensure = 'present'
  } elsif $::sensu::purge =~ Hash {
    if $::sensu::purge['config'] {
      $ensure = 'absent'
    } else {
      $ensure = undef
    }
  } elsif $::sensu::purge {
    $ensure = 'absent'
  } else {
    $ensure = undef
  }

  if $ensure != undef {
    if $ensure == 'present' {
      $file_ensure = 'file'
    } else {
      $file_ensure = $ensure
    }

    $file_notify = $::sensu::manage_services ? {
      true  => $::sensu::enterprise_dashboard ? {
        true => $::osfamily ? {
          'windows' => undef,
          default   => Service['sensu-enterprise-dashboard'],
        },
        false => undef,
      },
      false => undef,
    }

    file { "${sensu::etc_dir}/dashboard.json":
      ensure => $file_ensure,
      owner  => 'sensu',
      group  => 'sensu',
      mode   => '0440',
      notify => $file_notify,
    }

    sensu_enterprise_dashboard_config { $::fqdn:
      ensure    => $ensure,
      base_path => $::sensu::enterprise_dashboard_base_path,
      host      => $::sensu::enterprise_dashboard_host,
      port      => $::sensu::enterprise_dashboard_port,
      refresh   => $::sensu::enterprise_dashboard_refresh,
      user      => $::sensu::enterprise_dashboard_user,
      pass      => $::sensu::enterprise_dashboard_pass,
      auth      => $::sensu::enterprise_dashboard_auth,
      ssl       => $::sensu::enterprise_dashboard_ssl,
      audit     => $::sensu::enterprise_dashboard_audit,
      github    => $::sensu::enterprise_dashboard_github,
      gitlab    => $::sensu::enterprise_dashboard_gitlab,
      ldap      => $::sensu::enterprise_dashboard_ldap,
      oidc      => $::sensu::enterprise_dashboard_oidc,
      custom    => $::sensu::enterprise_dashboard_custom,
      notify    => $file_notify,
    }

    sensu_enterprise_dashboard_api_config { 'api1.example.com':
      ensure => absent,
      notify => $file_notify,
    }

    sensu_enterprise_dashboard_api_config { 'api2.example.com':
      ensure => absent,
      notify => $file_notify,
    }
  }

  # Service
  if $::sensu::manage_services and $::sensu::enterprise_dashboard {

    $service_ensure = $::sensu::enterprise_dashboard ? {
      true  => 'running',
      false => 'stopped',
    }

    if $::osfamily != 'windows' {
      service { 'sensu-enterprise-dashboard':
        ensure     => $service_ensure,
        enable     => $::sensu::enterprise_dashboard,
        hasrestart => $hasrestart,
        subscribe  => [
          Package['sensu-enterprise-dashboard'],
          Class['sensu::redis::config'],
        ],
      }
    }
  }
}
