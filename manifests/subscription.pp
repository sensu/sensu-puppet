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
#
define sensu::subscription (
  $ensure       = 'present',
) {

  validate_re($ensure, ['^present$', '^absent$'] )

  file { "/etc/sensu/conf.d/subscription_${name}.json":
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0444',
    before  => Sensu_client_subscription[$name],
  }

  sensu_client_subscription { $name:
    ensure  => $ensure,
    notify  => Class['sensu::client::service'],
  }

}
