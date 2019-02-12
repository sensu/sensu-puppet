# @summary Manage Sensu agent
#
# Class to manage the Sensu agent.
#
# @example
#   class { 'sensu::agent':
#     backends    => ['sensu-backend.example.com:8081'],
#     config_hash => {
#       'subscriptions => ['linux', 'apache-servers'],
#     },
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
# @param backends
#   Array of sensu backends to pass to `backend-url` config option.
#   The protocol prefix of `ws://` or `wss://` are optional and will be determined
#   based on `sensu::use_ssl` parameter by default.
#   Passing `backend-url` as part of `config_hash` takes precedence.
# @param show_diff
#   Sets show_diff parameter for agent.yml configuration file
#
class sensu::agent (
  Optional[String] $version = undef,
  String $package_name = 'sensu-go-agent',
  String $service_name = 'sensu-agent',
  String $service_ensure = 'running',
  Boolean $service_enable = true,
  Hash $config_hash = {},
  Array[Sensu::Backend_URL] $backends = ['localhost:8081'],
  Boolean $show_diff = true,
) {

  include ::sensu

  $etc_dir = $::sensu::etc_dir
  $ssl_dir = $::sensu::ssl_dir
  $use_ssl = $::sensu::use_ssl
  $_version = pick($version, $::sensu::version)

  if $use_ssl {
    $backend_protocol = 'wss'
    $ssl_config = {
      'trusted-ca-file' => "${ssl_dir}/ca.crt",
    }
    $service_subscribe = Class['::sensu::ssl']
  } else {
    $backend_protocol = 'ws'
    $ssl_config = {}
    $service_subscribe = undef
  }
  $backend_urls = $backends.map |$backend| {
    if 'ws://' in $backend or 'wss://' in $backend {
      $backend
    } else {
      "${backend_protocol}://${backend}"
    }
  }
  $default_config = {
    'backend-url' => $backend_urls,
  }
  $config = $default_config + $ssl_config + $config_hash

  package { 'sensu-go-agent':
    ensure  => $_version,
    name    => $package_name,
    before  => File['sensu_etc_dir'],
    require => $::sensu::package_require,
  }

  file { 'sensu_agent_config':
    ensure    => 'file',
    path      => "${etc_dir}/agent.yml",
    content   => to_yaml($config),
    show_diff => $show_diff,
    require   => Package['sensu-go-agent'],
    notify    => Service['sensu-agent'],
  }

  service { 'sensu-agent':
    ensure    => $service_ensure,
    enable    => $service_enable,
    name      => $service_name,
    subscribe => $service_subscribe,
  }
}
