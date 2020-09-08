# @summary Default sensu agent resources
# @api private
#
class sensu::backend::agent_resources {
  include sensu::backend

  sensu_cluster_role { 'puppet:agent_entity_config':
    ensure => 'present',
    rules  => [
      {
        'verbs'     => ['*'],
        'resources' => [
          'entities',
        ],
      },
      {
        'verbs'     => ['get', 'list'],
        'resources' => ['namespaces'],
      },
    ],
  }

  sensu_cluster_role_binding { 'puppet:agent_entity_config':
    ensure   => 'present',
    role_ref => {'type' => 'ClusterRole', 'name' => 'puppet:agent_entity_config'},
    subjects => [
      {
        'type' => 'Group',
        'name' => 'puppet:agent_entity_config',
      },
    ],
  }

  sensu_user { 'puppet-agent_entity_config':
    ensure   => 'present',
    disabled => false,
    groups   => 'puppet:agent_entity_config',
    password => $sensu::_agent_entity_config_password,
  }
}
