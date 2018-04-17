# @summary Manage Sensu agent
#
# Class to manage the Sensu agent.
#
# @param version Version of sensu to install.  Defaults to `installed` to support
#   Windows MSI packaging and to avoid surprising upgrades.
#
class sensu::agent (
  Optional[String] $version = undef,
  String $package_name = 'sensu-agent',
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

  package { 'sensu-agent':
    ensure => $_version,
    name   => $package_name,
    before => File['sensu_etc_dir'],
  }

  file { 'sensu_agent_config':
    ensure   => 'file',
    path     => "${etc_dir}/agent.yml",
    content  => to_yaml($config_hash),
    require  => Package['sensu-agent'],
    notify   => Service['sensu-agent'],
  }

  service { 'sensu-agent':
    ensure => $service_ensure,
    enable => $service_enable,
    name   => $service_name,
  }
}
