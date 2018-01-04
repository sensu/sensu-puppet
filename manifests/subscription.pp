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

  # Remove any from title any char which is not a letter, a number
  # or the . and - chars. Needed for safe path names.
  $sanitized_name=regsubst($name, '[^0-9A-Za-z.-]', '_', 'G')

  file { "${::sensu::conf_dir}/subscription_${sanitized_name}.json":
    ensure => $ensure,
    owner  => $::sensu::user,
    group  => $::sensu::group,
    mode   => $::sensu::file_mode,
    before => Sensu_client_subscription[$name],
  }

  sensu_client_subscription { $name:
    ensure    => $ensure,
    base_path => $::sensu::conf_dir,
    file_name => "subscription_${sanitized_name}.json",
    custom    => $custom,
    notify    => $::sensu::client_service,
  }
}
