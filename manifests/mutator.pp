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
  $command,
  $ensure       = 'present',
  $timeout      = undef,
  # Used to install the mutator
  $source       = undef,
  $install_path = '/etc/sensu/mutators',
) {

  validate_re($name, '^[\w\.-]+$')
  validate_re($ensure, ['^present$', '^absent$'] )
  if $timeout { validate_re($timeout, '^\d+$') }

  if $sensu::server {
    $notify_services = Class['sensu::server::service']
  } else {
    $notify_services = []
  }

  if $source {

    $filename = inline_template('<%= scope.lookupvar(\'source\').split(\'/\').last %>')
    $mutator = "${install_path}/${filename}"

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
