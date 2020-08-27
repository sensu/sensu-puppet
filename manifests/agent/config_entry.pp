# @summary Add custom agent config entry
#
# @example
#   sensu::agent::config_entry { 'disable-api'': value => true }

# @param key
#   Key of the config entry to add to agent.yml, defaults to `$name`.
# @param value
#   Config entry value to add to agent.yml
# @param order
#   Order of the datacat fragment
#
define sensu::agent::config_entry (
  Any $value,
  String[1] $key   = $name,
  String[1] $order = '50',
) {
  datacat_fragment { "sensu_agent_config-entry-${name}":
    target => 'sensu_agent_config',
    data   => {
      $key => $value,
    },
    order  => $order,
  }
}
