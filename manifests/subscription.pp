# = Define: sensu::subscription
#
# Defines Sensu subscriptions
#
# == Parameters
#
# [*ensure*]
#   String. Whether the check should be present or not
#   Default: present
#   Valid values: present, absent

# [*custom*]
#   Hash.  Custom client variables
#   Default: {}
#
define sensu::subscription (
  $ensure       = 'present',
  $custom       = {},
) {

  validate_re($ensure, ['^present$', '^absent$'] )

  file { "${sensu::conf_dir}/subscription_${name}.json":
    ensure => $ensure,
    owner  => $sensu::user,
    group  => $sensu::group,
    mode   => $sensu::file_mode,
    before => Sensu_client_subscription[$name],
  }

  sensu_client_subscription { $name:
    ensure    => $ensure,
    base_path => $sensu::conf_dir,
    custom    => $custom,
    notify    => Class['sensu::client::service'],
  }

}
