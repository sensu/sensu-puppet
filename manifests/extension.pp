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
  $ensure       = 'present',
  # Used to install the handler
  $source       = undef,
  $install_path = '/etc/sensu/extensions',
  # Handler specific config
  $config       = {},
) {

  validate_re($ensure, ['^present$', '^absent$'] )
  validate_re($source, ['^puppet://'] )

  if $sensu::client {
    $notify_services = Class['sensu::client::service']
  } else {
    $notify_services = []
  }

  $filename = inline_template('<%= scope.lookupvar(\'source\').split(\'/\').last %>')
  $handler = "${install_path}/${filename}"

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
