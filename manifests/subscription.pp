# = Define: sensu::subscription
#
# Defines Sensu subscriptions
#
# == Parameters
#

define sensu::subscription (
  $ensure       = 'present',
  $purge_config = $sensu::purge_config,
) {

  if $purge_config {
    file { "/etc/sensu/conf.d/subscription_${name}.json": ensure => $ensure, before => Sensu_client_subscription[$name] }
  }

  sensu_client_subscription { $name: ensure => $ensure }

}
