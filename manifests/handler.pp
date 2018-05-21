# @summary sensu::handler
#
# Defines Sensu handlers
#
# @param ensure Whether the check should be present or not
#
# @param type Type of handler
#
# @param command Command to run as the handler when type=pipe
#
# @param handlers Handlers to use when type=set
#
# @param severities Severities handler is valid for
#
# @param exchange Exchange information used when type=amqp
#   Keys: host, port
#
# @param pipe Pipe information used when type=transport
#   Keys: name, type, options
#
# @param socket Socket information when type=tcp or type=udp
#   Keys: host, port
#
# @param filters Filter commands to apply
#
# @param source Source of the puppet handler
#
# @param install_path Path to install the handler
#
# @param config Handler specific config
#
# @param timeout Handler timeout configuration
#
# @param handle_flapping If events in the flapping state should be handled.
#
# @param handle_silenced If events in the silenced state should be handled.
#
# @param mutator The handle mutator.
#   Valid values: Any kind of data which can be added to the handler mutator.
#
# @param subdue The handle subdue.
#   Valid values: Any kind of data which can be added to the handler subdue.
#
define sensu::handler(
  Enum['present','absent'] $ensure = 'present',
  Enum['pipe','tcp','udp','amqp','set','transport'] $type = 'pipe',
  Optional[String] $command        = undef,
  Optional[Array] $handlers        = undef,
  Array $severities      = ['ok', 'warning', 'critical', 'unknown'],
  Optional[Hash] $exchange         = undef,
  Optional[Hash] $pipe             = undef,
  Any $mutator                     = undef,
  Optional[Hash] $socket           = undef,
  Array $filters                   = [],
  # Used to install the handler
  Optional[Pattern[/^puppet:\/\//]] $source = undef,
  String $install_path             = $::osfamily ? {
    'windows' => 'C:/opt/sensu/handlers',
    default   => '/etc/sensu/handlers',
  },
  # Handler specific config
  Optional[Hash] $config           = undef,
  Any $subdue                      = undef,
  Optional[Integer] $timeout       = undef,
  Boolean $handle_flapping         = false,
  Boolean $handle_silenced         = false,
) {

  if $subdue{ fail('Subdue at handler is deprecated since sensu 0.26. See https://sensuapp.org/docs/0.26/overview/changelog.html#core-v0-26-0')}


  if $type == 'pipe' and $ensure != 'absent' and !$command and !$source and !$mutator {
    fail('command must be set with type pipe')
  }
  if ($type == 'tcp' or $type == 'udp') and !$socket {
    fail("socket must be set with type ${type}")
  }

  if $type == 'amqp' and !$exchange {
    fail('exchange must be set with type amqp')
  }

  if $type == 'transport' and !$pipe {
    fail('pipe must be set with type transport')
  }

  if $type == 'set' and !$handlers {
    fail('handlers must be set with type set')
  }

  if $::sensu::server {
    $notify_services = Class['sensu::server::service']
  } else {
    $notify_services = []
  }

  $file_ensure = $ensure ? {
    'absent' => 'absent',
    default  => 'file'
  }

  if $source {
    $handler = "${install_path}/${basename($source)}"

    ensure_resource('file', $handler, {
      ensure => $file_ensure,
      owner  => $::sensu::user,
      group  => $::sensu::group,
      mode   => $::sensu::dir_mode,
      source => $source,
    })

    $command_real = $command ? {
      undef   => $handler,
      default => $command,
    }
  } else {
    $command_real = $command
  }

  # handler configuration may contain "secrets"
  file { "${::sensu::conf_dir}/handlers/${name}.json":
    ensure => $file_ensure,
    owner  => $::sensu::user,
    group  => $::sensu::group,
    mode   => $::sensu::file_mode,
    before => Sensu_handler[$name],
  }

  sensu_handler { $name:
    ensure          => $ensure,
    base_path       => "${::sensu::conf_dir}/handlers",
    type            => $type,
    command         => $command_real,
    handlers        => $handlers,
    severities      => $severities,
    exchange        => $exchange,
    pipe            => $pipe,
    socket          => $socket,
    mutator         => $mutator,
    filters         => $filters,
    config          => $config,
    timeout         => $timeout,
    handle_flapping => $handle_flapping,
    handle_silenced => $handle_silenced,
    notify          => $notify_services,
    require         => File["${::sensu::conf_dir}/handlers"],
  }
}
