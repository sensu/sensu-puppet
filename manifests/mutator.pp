# @summary Manages sensu mutators
#
# This define manages Sense mutators
#
# @param ensure Whether the check should be present or not
#
# @param command Command to run.
#
# @param timeout The mutator execution duration timeout in seconds (hard stop).
#
# @param source Source of the puppet mutator
#
# @param install_path Path to install the mutator
#
define sensu::mutator(
  String $command,
  Enum['present','absent'] $ensure   = 'present',
  Optional[Numeric] $timeout         = undef,
  # Used to install the mutator
  Optional[String] $source           = undef,
  Stdlib::Absolutepath $install_path = '/etc/sensu/mutators',
) {

  assert_type(Pattern[/^[\w\.-]+$/], $name)

  include ::sensu

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

  file { "${::sensu::conf_dir}/mutators/${name}.json":
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
    require => File["${::sensu::conf_dir}/mutators"],
  }
}
