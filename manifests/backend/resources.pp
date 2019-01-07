# @summary Default sensu resources
# @api private
#
class sensu::backend::resources {
  sensu_namespace { 'default':
    ensure => 'present',
  }

  sensu_user { 'agent':
    ensure   => 'present',
    disabled => false,
    password => 'P@ssw0rd!',
    groups   => ['system:agents'],
  }

  sensu_cluster_role { 'admin':
    ensure => 'present',
    rules  => [
      {
        'verbs'     => ['*'],
        'resources' => [
          'assets',
          'checks',
          'entities',
          'extensions',
          'events',
          'filters',
          'handlers',
          'hooks',
          'mutators',
          'silenced',
          'roles',
          'rolebindings',
        ],
      },
      {
        'verbs'     => ['get', 'list'],
        'resources' => ['namespaces'],
      },
    ],
  }
  sensu_cluster_role { 'cluster-admin':
    ensure => 'present',
    rules  => [
      {
        'verbs'     => ['*'],
        'resources' => ['*'],
      },
    ],
  }
  sensu_cluster_role { 'edit':
    ensure => 'present',
    rules  => [
      {
        'verbs'     => ['*'],
        'resources' => [
          'assets',
          'checks',
          'entities',
          'extensions',
          'events',
          'filters',
          'handlers',
          'hooks',
          'mutators',
          'silenced',
        ],
      },
      {
        'verbs'     => ['get', 'list'],
        'resources' => ['namespaces'],
      },
    ],
  }
  sensu_cluster_role { 'system:agent':
    ensure => 'present',
    rules  => [
      {
        'verbs'     => ['*'],
        'resources' => ['events'],
      },
    ],
  }
  sensu_cluster_role { 'system:user':
    ensure => 'present',
    rules  => [
      {
        'verbs'     => ['get', 'update'],
        'resources' => ['localselfuser'],
      },
      {
        'verbs'     => ['get', 'list'],
        'resources' => ['namespaces'],
      },
    ],
  }
  sensu_cluster_role { 'view':
    ensure => 'present',
    rules  => [
      {
        'verbs'     => ['get', 'list'],
        'resources' => [
          'assets',
          'checks',
          'entities',
          'extensions',
          'events',
          'filters',
          'handlers',
          'hooks',
          'mutators',
          'silenced',
          'namespaces',
        ],
      },
    ],
  }

  sensu_cluster_role_binding { 'cluster-admin':
    ensure   => 'present',
    role_ref => 'cluster-admin',
    subjects => [
      {
        'type' => 'Group',
        'name' => 'cluster-admins'
      },
    ],
  }
  sensu_cluster_role_binding { 'system:agent':
    ensure   => 'present',
    role_ref => 'system:agent',
    subjects => [
      {
        'type' => 'Group',
        'name' => 'system:agents'
      },
    ],
  }
  sensu_cluster_role_binding { 'system:user':
    ensure   => 'present',
    role_ref => 'system:user',
    subjects => [
      {
        'type' => 'Group',
        'name' => 'system:users'
      },
    ],
  }
}
