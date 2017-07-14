# = Define: sensu::extension
#
# Defines Sensu extensions
#
# == Parameters
#
# [*ensure*]
#   String. Whether the check should be present or not
#   Default: present
#   Valid values: present, absent
#
# [*source*]
#   String.  Source of the puppet extension
#   Default: undef
#
# [*install_path*]
#   String.  Path to install the extension
#   Default: /etc/sensu/extensions
#
# [*config*]
#   Hash.  Extension specific config
#   Default: undef
#
#
define sensu::extension(
  Enum['present','absent'] $ensure       = 'present',
  # Used to install the handler
  Optional[Pattern[/^puppet:\/\//]] $source       = undef,
  String $install_path = '/etc/sensu/extensions',
  # Handler specific config
  Hash $config       = {},
) {

  if $::sensu::client {
    $notify_services = Class['sensu::client::service']
  } else {
    $notify_services = []
  }

  $handler = "${install_path}/${basename($source)}"

  $file_ensure = $ensure ? {
    'absent'  => 'absent',
    default   => 'file'
  }

  file { $handler:
    ensure => $file_ensure,
    owner  => 'sensu',
    group  => 'sensu',
    mode   => '0555',
    source => $source,
  }

  file { "/etc/sensu/conf.d/extensions/${name}.json":
    ensure => $ensure,
    owner  => 'sensu',
    group  => 'sensu',
    mode   => '0444',
    before => Sensu_extension[$name],
  }

  sensu_extension { $name:
    ensure  => $ensure,
    config  => $config,
    notify  => $notify_services,
    require => File['/etc/sensu/conf.d/extensions'],
  }
}
