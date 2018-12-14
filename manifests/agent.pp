# @summary Manage Sensu agent
#
# Class to manage the Sensu agent.
#
# @example
#   class { 'sensu::agent':
#     config_hash => {
#       'backend-url' => 'ws://sensu-backend.example.com:8081',
#     }
#   }
#
# @param version
#   Version of sensu agent to install.  Defaults to `installed` to support
#   Windows MSI packaging and to avoid surprising upgrades.
# @param package_name
#   Name of Sensu agent package.
# @param service_name
#   Name of the Sensu agent service.
# @param service_ensure
#   Sensu agent service ensure value.
# @param service_enable
#   Sensu agent service enable value.
# @param config_hash
#   Sensu agent configuration hash used to define agent.yml.
#
class sensu::agent (
  Optional[String] $version = undef,
  String $package_name = 'sensu-go-agent',
  String $service_name = 'sensu-agent',
  String $service_ensure = 'running',
  Boolean $service_enable = true,
  Hash $config_hash = {},
) {

  include ::sensu

  $etc_dir = $::sensu::etc_dir

  if $version == undef {
    $_version= $::sensu::version
  } else {
    $_version= $version
  }

  package { 'sensu-go-agent':
    ensure  => $_version,
    name    => $package_name,
    before  => File['sensu_etc_dir'],
    require => Class['::sensu::repo'],
  }

  file { 'sensu_agent_config':
    ensure  => 'file',
    path    => "${etc_dir}/agent.yml",
    content => to_yaml($config_hash),
    require => Package['sensu-go-agent'],
    notify  => Service['sensu-agent'],
  }

  service { 'sensu-agent':
    ensure => $service_ensure,
    enable => $service_enable,
    name   => $service_name,
  }
}
