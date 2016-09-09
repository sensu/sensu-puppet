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
# [*subdue*]
#   Hash.  Handler subdue configuration
#   Default: undef
#
define sensu::handler(
  $ensure       = 'present',
  $type         = 'pipe',
  $command      = undef,
  $handlers     = undef,
  $severities   = ['ok', 'warning', 'critical', 'unknown'],
  $exchange     = undef,
  $pipe         = undef,
  $mutator      = undef,
  $socket       = undef,
  $filters      = [],
  # Used to install the handler
  $source       = undef,
  $install_path = '/etc/sensu/handlers',
  # Handler specific config
  $config       = undef,
  $subdue       = undef,
) {

  validate_re($ensure, ['^present$', '^absent$'] )
  validate_re($type, [ '^pipe$', '^tcp$', '^udp$', '^amqp$', '^set$', '^transport$' ] )
  if $exchange { validate_hash($exchange) }
  if $pipe { validate_hash($pipe) }
  if $socket { validate_hash($socket) }
  validate_array($severities, $filters)
  if $source { validate_re($source, ['^puppet://'] ) }

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

  if $sensu::server {
    $notify_services = Class['sensu::server::service']
  } else {
    $notify_services = []
  }

  $file_ensure = $ensure ? {
    'absent' => 'absent',
    default  => 'file'
  }

  if $source {
    $filename = inline_template('<%= scope.lookupvar(\'source\').split(\'/\').last %>')
    $handler = "${install_path}/${filename}"

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
    ensure     => $ensure,
    type       => $type,
    command    => $command_real,
    handlers   => $handlers,
    severities => $severities,
    exchange   => $exchange,
    pipe       => $pipe,
    socket     => $socket,
    mutator    => $mutator,
    filters    => $filters,
    config     => $config,
    subdue     => $subdue,
    notify     => $notify_services,
    require    => File['/etc/sensu/conf.d/handlers'],
  }

}
