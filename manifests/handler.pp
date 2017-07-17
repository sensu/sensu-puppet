# = Define: sensu::handler
#
# Defines Sensu handlers
#
# == Parameters
#
# [*ensure*]
#   String. Whether the check should be present or not
#   Default: present
#   Valid values: present, absent
#
# [*type*]
#   String.  Type of handler
#   Default: pipe
#   Valid values: pipe, tcp, udp, amqp, transport, set
#
# [*command*]
#   String.  Command to run as the handler when type=pipe
#   Default: undef
#
# [*handlers*]
#   Array of Strings.  Handlers to use when type=set
#   Default: undef
#
# [*severities*]
#   Array of Strings.  Severities handler is valid for
#   Default: ['ok', 'warning', 'critical', 'unknown']
#   Valid values: ok, warning, critical, unknown
#
# [*exchange*]
#   Hash.  Exchange information used when type=amqp
#   Keys: host, port
#   Default: undef
#
# [*pipe*]
#   Hash.  Pipe information used when type=transport
#   Keys: name, type, options
#   Default: undef
#
# [*socket*]
#   Hash.  Socket information when type=tcp or type=udp
#   Keys: host, port
#   Default: undef
#
# [*filters*]
#   Array.  Filter command to apply
#   Default: []
#
# [*source*]
#   String.  Source of the puppet handler
#   Default: undef
#
# [*install_path*]
#   String.  Path to install the handler
#   Default: /etc/sensu/handlers
#
# [*config*]
#   Hash.  Handler specific config
#   Default: undef
#
# [*timeout*]
#   Integer.  Handler timeout configuration
#   Default: undef
#
# [*handle_flapping*]
#   Boolean.  If events in the flapping state should be handled.
#   Default: false.
#   Valid values: true, false
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
  String $install_path             = '/etc/sensu/handlers',
  # Handler specific config
  Optional[Hash] $config           = undef,
  Any $subdue                      = undef,
  Optional[Integer] $timeout       = undef,
  Boolean $handle_flapping         = false,
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
      owner  => 'sensu',
      group  => 'sensu',
      mode   => '0555',
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
  file { "/etc/sensu/conf.d/handlers/${name}.json":
    ensure => $file_ensure,
    owner  => 'sensu',
    group  => 'sensu',
    mode   => '0440',
    before => Sensu_handler[$name],
  }

  sensu_handler { $name:
    ensure          => $ensure,
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
    notify          => $notify_services,
    require         => File['/etc/sensu/conf.d/handlers'],
  }
}
