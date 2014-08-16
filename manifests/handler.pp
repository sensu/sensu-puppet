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
# [*socket*]
#   Hash.  Socket information when type=tcp or type=udp
#   Keys: host, port
#   Default: undef
#
# [*filters*]
#   Hash.  Filter command to apply
#   Default: undef
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
#
define sensu::handler(
  $ensure       = 'present',
  $type         = 'pipe',
  $command      = undef,
  $handlers     = undef,
  $severities   = ['ok', 'warning', 'critical', 'unknown'],
  $exchange     = undef,
  $mutator      = undef,
  $socket       = undef,
  $filters      = undef,
  # Used to install the handler
  $source       = undef,
  $install_path = '/etc/sensu/handlers',
  # Handler specific config
  $config       = undef,
) {

  validate_re($ensure, ['^present$', '^absent$'] )
  validate_re($type, [ '^pipe$', '^tcp$', '^udp$', '^amqp$', '^set$', '^transport$' ] )
  if $exchange { validate_hash($exchange) }
  if $socket { validate_hash($socket) }
  validate_array($severities)
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

  if $type == 'set' and !$handlers {
    fail('handlers must be set with type set')
  }

  if $sensu::server {
    $notify_services = Class['sensu::server::service']
  } else {
    $notify_services = []
  }

  if $source {

    $filename = inline_template('<%= scope.lookupvar(\'source\').split(\'/\').last %>')
    $command_real = "${install_path}/${filename}"

    $file_ensure = $ensure ? {
      'absent'  => 'absent',
      default   => 'file'
    }

    file { $command_real:
      ensure  => $file_ensure,
      owner   => 'sensu',
      group   => 'sensu',
      mode    => '0555',
      source  => $source,
    }
  } else {
    $command_real = $command
  }

  file { "/etc/sensu/conf.d/handlers/${name}.json":
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0444',
    before  => Sensu_handler[$name],
  }

  sensu_handler { $name:
    ensure     => $ensure,
    type       => $type,
    command    => $command_real,
    handlers   => $handlers,
    severities => $severities,
    exchange   => $exchange,
    socket     => $socket,
    mutator    => $mutator,
    filters    => $filters,
    config     => $config,
    notify     => $notify_services,
    require    => File['/etc/sensu/conf.d/handlers'],
  }

}
