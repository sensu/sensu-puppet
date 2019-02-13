# @summary Defines Sensu extensions
#
# This define manages Sensu extensions
#
# @param ensure Whether the check should be present or not
#
# @param source Source of the puppet extension
#
# @param install_path Path where to install the extension
#
# @param config Extension specific config
#
define sensu::extension (
  Enum['present','absent'] $ensure          = 'present',
  # Used to install the handler
  Optional[Pattern[/^puppet:\/\//]] $source = undef,
  String $install_path                      = '/etc/sensu/extensions',
  # Handler specific config
  Hash $config                              = {},
) {

  include ::sensu

  if $::sensu::client and $::sensu::manage_services {
    $notify_services = Service['sensu-client']
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

  file { "${::sensu::conf_dir}/extensions/${name}.json":
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
    require => File["${::sensu::conf_dir}/extensions"],
  }
}
