# @summary Manage Sensu agent
#
# Class to manage the Sensu agent.
#
# @example
#   class { 'sensu::agent':
#     backends      => ['sensu-backend.example.com:8081'],
#     subscriptions => ['linux', 'apache-servers'],
#     config_hash   => {
#       'log-level' => 'info',
#     },
#   }
#
# @param version
#   Version of sensu agent to install.  Defaults to `installed` to support
#   Windows MSI packaging and to avoid surprising upgrades.
# @param package_source
#   Source of package for installing Windows.
#   Paths with http:// or https:// will be downloaded
#   Paths with puppet:// or absolute filesystem paths will also be installed.
# @param package_download_path
#   Where to download the MSI for Windows. Defaults to `C:\`.
#   This parameter only used when `package_source` is an URL or when it's a puppet source (`puppet://`).
# @param package_name
#   Name of Sensu agent package.
# @param service_env_vars_file
#   Path to the agent service ENV variables file.
#   Debian based default: `/etc/default/sensu-agent`
#   RedHat based default: `/etc/sysconfig/sensu-agent`
# @param service_env_vars
#   Hash of environment variables loaded by sensu-agent service
# @param service_name
#   Name of the Sensu agent service.
# @param service_ensure
#   Sensu agent service ensure value.
# @param service_enable
#   Sensu agent service enable value.
# @param service_path
#   The path to sensu-agent service executable
# @param config_hash
#   Sensu agent configuration hash used to define agent.yml.
# @param backends
#   Array of sensu backends to pass to `backend-url` config option.
#   Default is `["${sensu::api_host}:8081"]`
#   The protocol prefix of `ws://` or `wss://` are optional and will be determined
#   based on `sensu::use_ssl` parameter by default.
#   Passing `backend-url` as part of `config_hash` takes precedence over this parameter.
# @param entity_name
#   The value for agent.yml `name`.
#   Passing `name` as part of `config_hash` takes precedence
# @param subscriptions
#   The agent subscriptions to define in agent.yml
#   Passing `subscriptions` as part of `config_hash` takes precedence
# @param annotations
#   The agent annotations value for agent.yml
#   Passing `annotations` as part of `config_hash` takes precedence
# @param labels
#   The agent labels value for agent.yml
#   Passing `labels` as part of `config_hash` takes precedence
# @param namespace
#   The agent namespace
#   Passing `namespace` as part of `config_hash` takes precedence
# @param redact
#   The agent entity redact list
#   Passing `redact` as part of `config_hash` takes precedence
#   Defaults come from Sensu documentation:
#   https://docs.sensu.io/sensu-go/latest/reference/agent/#security-configuration-flags
# @param show_diff
#   Sets show_diff parameter for agent.yml configuration file
# @param log_file
#   Path to agent log file, only for Windows.
#   Defaults to `C:\ProgramData\sensu\log\sensu-agent.log`
# @param agent_entity_config_provider
#   The provider to use when managing sensu_agent_entity_config resources
#
class sensu::agent (
  Optional[String] $version = undef,
  Optional[String[1]] $package_source = undef,
  Optional[Stdlib::Absolutepath] $package_download_path = undef,
  String $package_name = 'sensu-go-agent',
  Optional[Stdlib::Absolutepath] $service_env_vars_file = undef,
  Hash $service_env_vars = {},
  String $service_name = 'sensu-agent',
  String $service_ensure = 'running',
  Boolean $service_enable = true,
  Stdlib::Absolutepath $service_path = '/usr/sbin/sensu-agent',
  Hash $config_hash = {},
  Optional[Array[Sensu::Backend_URL]] $backends = undef,
  String[1] $entity_name = $facts['networking']['fqdn'],
  Optional[Array[String[1]]] $subscriptions = undef,
  Optional[Hash[String[1],String]] $annotations = undef,
  Optional[Hash[String[1],String]] $labels = undef,
  String[1] $namespace = 'default',
  Array[String[1]] $redact = ['password','passwd','pass','api_key','api_token','access_key','secret_key','private_key','secret'],
  Boolean $show_diff = true,
  Optional[Stdlib::Absolutepath] $log_file = undef,
  Enum['sensuctl','sensu_api'] $agent_entity_config_provider = 'sensu_api',
) {

  include sensu
  include sensu::common
  include sensu::api
  if $agent_entity_config_provider == 'sensuctl' {
    warning('Class[sensu::agent]: Using agent_entity_config_provider is deprecated at this time, forcing use of sensu_api provider')
  }

  $_version = pick($version, $sensu::version)
  $_backends = pick($backends, ["${sensu::api_host}:8081"])

  if $sensu::use_ssl {
    $backend_protocol = 'wss'
    $ssl_config = {
      'trusted-ca-file' => $sensu::trusted_ca_file_path,
    }
    $service_subscribe = Class['sensu::ssl']
  } else {
    $backend_protocol = 'ws'
    $ssl_config = {}
    $service_subscribe = undef
  }
  $backend_urls = $_backends.map |$backend| {
    if 'ws://' in $backend or 'wss://' in $backend {
      $backend
    } else {
      "${backend_protocol}://${backend}"
    }
  }
  $default_config = {
    'backend-url'   => $backend_urls,
    'name'          => $entity_name,
    'subscriptions' => $subscriptions,
    'annotations'   => $annotations,
    'labels'        => $labels,
    'namespace'     => $namespace,
    'redact'        => $redact,
    'password'      => $sensu::agent_password,
  }
  $config = filter($default_config + $ssl_config + $config_hash) |$key, $value| { $value =~ NotUndef }
  if $config['subscriptions'] {
    $config['subscriptions'].each |$s| {
      sensu::agent::subscription { $s: }
    }
  }
  if $config['labels'] {
    $config['labels'].each |$key, $value| {
      sensu::agent::label { $key:
        value => $value,
      }
    }
  }
  if $config['annotations'] {
    $config['annotations'].each |$key, $value| {
      sensu::agent::annotation { $key:
        value => $value,
      }
    }
  }
  sensu_agent_entity_setup { 'puppet':
    url      => $sensu::api_url,
    username => 'puppet-agent_entity_config',
    password => $sensu::_agent_entity_config_password,
  }

  $_service_env_vars = $service_env_vars.map |$key,$value| {
    "${key}=\"${value}\""
  }
  $_service_env_vars_lines = ['# This file is being maintained by Puppet.','# DO NOT EDIT'] + $_service_env_vars

  if $facts['os']['family'] == 'windows' {
    $sensu_agent_exe = "C:\\Program Files\\sensu\\sensu-agent\\bin\\sensu-agent.exe"
    exec { 'install-agent-service':
      command => "C:\\windows\\system32\\cmd.exe /c \"\"${sensu_agent_exe}\" service install --config-file \"${sensu::agent_config_path}\" --log-file \"${log_file}\"\"", # lint:ignore:140chars
      unless  => "C:\\windows\\system32\\sc.exe query SensuAgent",
      before  => Service['sensu-agent'],
      require => [
        Package['sensu-go-agent'],
        File['sensu_agent_config'],
      ],
    }
    if $package_source and ($package_source =~ Stdlib::HTTPSUrl or $package_source =~ Stdlib::HTTPUrl) {
      $package_provider = undef
      $package_source_basename = basename($package_source)
      $_package_source = "${package_download_path}\\${package_source_basename}"
      archive { 'sensu-go-agent.msi':
        source  => $package_source,
        path    => $_package_source,
        extract => false,
        cleanup => false,
        before  => Package['sensu-go-agent'],
      }
    } elsif $package_source and $package_source =~ /^puppet:/ {
      $package_provider = undef
      $package_source_basename = basename($package_source)
      $_package_source = "${package_download_path}\\${package_source_basename}"
      file { 'sensu-go-agent.msi':
        ensure => 'file',
        path   => $_package_source,
        source => $package_source,
        before => Package['sensu-go-agent'],
      }
    } elsif $package_source {
        $package_provider = undef
        $_package_source = $package_source
    } else {
      include chocolatey
      $package_provider = 'chocolatey'
      $_package_source = $package_source
    }
  } else {
    $package_provider = undef
    $_package_source = undef
  }

  # See https://docs.sensu.io/sensu-go/latest/installation/upgrade/
  # Only necessary for Puppet < 6.1.0,
  # See https://github.com/puppetlabs/puppet/commit/f8d5c60ddb130c6429ff12736bfdb4ae669a9fd4
  if versioncmp($facts['puppetversion'],'6.1.0') < 0 and $facts['service_provider'] == 'systemd' {
    Package['sensu-go-agent'] ~> Class['systemd::systemctl::daemon_reload']
    Class['systemd::systemctl::daemon_reload'] -> Service['sensu-agent']
  }

  package { 'sensu-go-agent':
    ensure   => $_version,
    name     => $package_name,
    source   => $_package_source,
    provider => $package_provider,
    before   => File['sensu_etc_dir'],
    require  => $sensu::package_require,
    notify   => Service['sensu-agent'],
  }

  datacat_collector { 'sensu_agent_config':
    template        => 'sensu/agent.yml.erb',
    template_body   => template_body('sensu/agent.yml.erb'),
    target_resource => File['sensu_agent_config'],
    target_field    => 'content',
  }

  datacat_fragment { 'sensu_agent_config-main':
    target => 'sensu_agent_config',
    data   => $config,
    order  => '01',
  }

  file { 'sensu_agent_config':
    ensure    => 'file',
    path      => $sensu::agent_config_path,
    owner     => $sensu::sensu_user,
    group     => $sensu::sensu_group,
    mode      => $sensu::file_mode,
    show_diff => $show_diff,
    require   => Package['sensu-go-agent'],
    notify    => Service['sensu-agent'],
  }

  if $service_env_vars_file {
    $_service_env_vars_content = join($_service_env_vars_lines, "\n")
    file { 'sensu-agent_env_vars':
      ensure    => 'file',
      path      => $service_env_vars_file,
      content   => "${_service_env_vars_content}\n",
      owner     => $sensu::sensu_user,
      group     => $sensu::sensu_group,
      mode      => $sensu::file_mode,
      show_diff => $show_diff,
      require   => Package['sensu-go-agent'],
      notify    => Service['sensu-agent'],
    }
  }
  # No built in way to read environment variables from a file for Windows
  if $facts['os']['family'] == 'windows' {
    $service_env_vars.each |$key,$value| {
      windows_env { $key:
        ensure    => 'present',
        value     => $value,
        mergemode => 'clobber',
        notify    => Service['sensu-agent'],
      }
    }
  }

  if $facts['service_provider'] == 'systemd' {
    systemd::dropin_file { 'sensu-agent-start.conf':
      unit    => 'sensu-agent.service',
      content => join([
        '[Service]',
        'ExecStart=',
        "ExecStart=${service_path} start -c ${sensu::agent_config_path}",
      ], "\n"),
      notify  => Service['sensu-agent'],
    }
  }

  service { 'sensu-agent':
    ensure    => $service_ensure,
    enable    => $service_enable,
    name      => $service_name,
    subscribe => $service_subscribe,
  }

  sensu_agent_entity_validator { $config['name']:
    namespace => $config['namespace'],
    provider  => 'sensu_api',
  }
}
