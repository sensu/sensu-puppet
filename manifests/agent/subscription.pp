# @summary Add agent subscription
#
# @example
#   sensu::agent::subscription { 'mysql': }
#
# @param subscription
#   Name of the subscription to add to agent.yml, defaults to `$name`.
# @param order
#   Order of the datacat fragment
#
define sensu::agent::subscription (
  String[1] $subscription = $name,
  String[1] $order        = '50',
) {
  datacat_fragment { "sensu_agent_config-subscription-${name}":
    target => 'sensu_agent_config',
    data   => {
      'subscriptions' => [$subscription],
    },
    order  => $order,
  }
}
