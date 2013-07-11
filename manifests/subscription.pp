# = Define: sensu::subscription
#
# Defines Sensu subscriptions
#
# == Parameters
#

define sensu::subscription (
  $ensure       = 'present',
) {

  file { "/etc/sensu/conf.d/subscription_${name}.json":
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0444',
    before  => Sensu_client_subscription[$name],
  }

  sensu_client_subscription { $name: ensure => $ensure }

}
