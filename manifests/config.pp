# @summary Defines Sensu check configurations
#
# This define manages Sensu check configurations.
#
# @param ensure Whether the check should be present or not
#   Valid values: present, absent
#
# @param config Check configuration for the client to use
#
# @param event Configuration to send with the event to handlers
#
define sensu::config (
  Enum['present','absent'] $ensure = 'present',
  Optional[Hash] $config = undef,
  Optional[Hash] $event  = undef,
) {

  file { "/etc/sensu/conf.d/checks/config_${name}.json":
    ensure => $ensure,
    owner  => 'sensu',
    group  => 'sensu',
    mode   => '0444',
    before => Sensu_check[$name],
  }

  sensu_check_config { $name:
    ensure => $ensure,
    config => $config,
    event  => $event,
    notify => $::sensu::client_service,
  }
}
