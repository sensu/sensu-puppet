# @summary Add agent subscription
#
# @example
#   sensu::agent::subscription { 'mysql': }
#
# @param subscription
#   Name of the subscription to add to agent.yml, defaults to `$name`.
# @param order
#   Order of the datacat fragment
# @param entity
#   Entity where to manage this subscription
# @param namespace
#   Namespace of entity to manage this subscription
#
define sensu::agent::subscription (
  String[1] $subscription = $name,
  String[1] $order        = '50',
  Optional[String[1]] $entity = undef,
  Optional[String[1]] $namespace = undef,
) {
  include sensu::agent
  if ! $entity {
    $_entity = $sensu::agent::config['name']
  } else{
    $_entity = $entity
  }
  if ! $namespace {
    $_namespace = $sensu::agent::config['namespace']
  } else {
    $_namespace = $namespace
  }

  datacat_fragment { "sensu_agent_config-subscription-${name}":
    target => 'sensu_agent_config',
    data   => {
      'subscriptions' => [$subscription],
    },
    order  => $order,
  }

  sensu_agent_entity_config { "sensu::agent::subscription ${name}":
    config    => 'subscriptions',
    value     => $subscription,
    entity    => $_entity,
    namespace => $_namespace,
    provider  => 'sensu_api',
  }
}
