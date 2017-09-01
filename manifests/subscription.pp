# @summary Manages Sensu subscriptions
#
# This define manages Sensu subscriptions
#
# @param ensure Whether the check should be present or not
#
# @param custom Custom client variables
#
define sensu::subscription (
  Enum['present','absent'] $ensure = 'present',
  Hash $custom                     = {},
) {

  include ::sensu

  file { "${::sensu::conf_dir}/subscription_${name}.json":
    ensure => $ensure,
    owner  => $::sensu::user,
    group  => $::sensu::group,
    mode   => $::sensu::file_mode,
    before => Sensu_client_subscription[$name],
  }

  sensu_client_subscription { $name:
    ensure    => $ensure,
    base_path => $::sensu::conf_dir,
    custom    => $custom,
    notify    => $::sensu::client_service,
  }
}
