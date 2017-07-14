# = Define: sensu::mutator
#
# Defines Sensu mutators
#
# == Parameters
#
# [*ensure*]
#   String. Whether the check should be present or not
#   Default: present
#   Valid values: present, absent
#
# [*command*]
#   String.  Command to run.
#   Default: undef
#
# [*timeout*]
#   Integer. The mutator execution duration timeout in seconds (hard stop).
#   Default: undef
#
# [*source*]
#   String.  Source of the puppet mutator
#   Default: undef
#
# [*install_path*]
#   String.  Path to install the mutator
#   Default: /etc/sensu/mutators
#
define sensu::mutator(
  String $command,
  Enum['present','absent'] $ensure       = 'present',
  Optional[Numeric] $timeout      = undef,
  # Used to install the mutator
  Optional[String] $source       = undef,
  Stdlib::Absolutepath $install_path = '/etc/sensu/mutators',
) {

  assert_type(Pattern[/^[\w\.-]+$/], $name)

  if $::sensu::server {
    $notify_services = Class['sensu::server::service']
  } else {
    $notify_services = []
  }

  if $source {
    $mutator = "${install_path}/${basename($source)}"

    $file_ensure = $ensure ? {
      'absent' => 'absent',
      default  => 'file'
    }

    file { $mutator:
      ensure => $file_ensure,
      owner  => 'sensu',
      group  => 'sensu',
      mode   => '0555',
      source => $source,
    }
  } else {
    $file_ensure = undef
  }

  file { "/etc/sensu/conf.d/mutators/${name}.json":
    ensure => $file_ensure,
    owner  => 'sensu',
    group  => 'sensu',
    mode   => '0440',
    before => Sensu_mutator[$name],
  }

  sensu_mutator { $name:
    ensure  => $ensure,
    command => $command,
    timeout => $timeout,
    require => File['/etc/sensu/conf.d/mutators'],
  }
}
