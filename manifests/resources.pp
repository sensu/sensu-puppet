# @summary Define sensu resources
#
# @param ad_auths
#   Hash of sensu_ad_auth resources
# @param assets
#   Hash of sensu_asset resources
# @param bonsai_assets
#   Hash of sensu_bonsai_asset resources
# @param checks
#   Hash of sensu_check resources
# @param cluster_members
#   Hash of sensu_cluster_member resources
# @param cluster_role_bindings
#   Hash of sensu_cluster_role_binding resources
# @param cluster_roles
#   Hash of sensu_cluster_role resources
# @param configs
#   Hash of sensu_config resources
# @param entities
#   Hash of sensu_entity resources
# @param etcd_replicators
#   Hash of sensu_etcd_replicator resources
# @param filters
#   Hash of sensu_filter resources
# @param handlers
#   Hash of sensu_handler resources
# @param hooks
#   Hash of sensu_hook resources
# @param ldap_auths
#   Hash of sensu_ldap_auth resources
# @param mutators
#   Hash of sensu_mutator resources
# @param namespaces
#   Hash of sensu_namespace resources
# @param oidc_auths
#   Hash of sensu_oidc_auth resources
# @param role_bindings
#   Hash of sensu_role_binding resources
# @param roles
#   Hash of sensu_role resources
# @param users
#   Hash of sensu_user resources
#
class sensu::resources (
  Hash $ad_auths = {},
  Hash $assets = {},
  Hash $bonsai_assets = {},
  Hash $checks = {},
  Hash $cluster_members = {},
  Hash $cluster_role_bindings = {},
  Hash $cluster_roles = {},
  Hash $configs = {},
  Hash $entities = {},
  Hash $etcd_replicators = {},
  Hash $filters = {},
  Hash $handlers = {},
  Hash $hooks = {},
  Hash $ldap_auths = {},
  Hash $mutators = {},
  Hash $namespaces = {},
  Hash $oidc_auths = {},
  Hash $role_bindings = {},
  Hash $roles = {},
  Hash $users = {},
) {
  $ad_auths.each |$name, $ad_auth| {
    sensu_ad_auth { $name:
      * => $ad_auth,
    }
  }
  $assets.each |$name, $asset| {
    sensu_asset { $name:
      * => $asset,
    }
  }
  $bonsai_assets.each |$name, $bonsai_asset| {
    sensu_bonsai_asset { $name:
      * => $bonsai_asset,
    }
  }
  $checks.each |$name, $check| {
    sensu_check { $name:
      * => $check,
    }
  }
    $cluster_members.each |$name, $cluster_member| {
    sensu_cluster_member { $name:
      * => $cluster_member,
    }
  }
  $cluster_role_bindings.each |$name, $cluster_role_binding| {
    sensu_cluster_role_binding { $name:
      * => $cluster_role_binding,
    }
  }
  $cluster_roles.each |$name, $cluster_role| {
    sensu_cluster_role { $name:
      * => $cluster_role,
    }
  }
  $configs.each |$name, $config| {
    sensu_config { $name:
      * => $config,
    }
  }
  $entities.each |$name, $entity| {
    sensu_entity { $name:
      * => $entity,
    }
  }
  $etcd_replicators.each |$name, $etcd_replicator| {
    sensu_etcd_replicator { $name:
      * => $etcd_replicator,
    }
  }
  $filters.each |$name, $filter| {
    sensu_filter { $name:
      * => $filter,
    }
  }
  $handlers.each |$name, $handler| {
    sensu_handler { $name:
      * => $handler,
    }
  }
  $hooks.each |$name, $hook| {
    sensu_hook { $name:
      * => $hook,
    }
  }
  $ldap_auths.each |$name, $ldap_auth| {
    sensu_ldap_auth { $name:
      * => $ldap_auth,
    }
  }
  $mutators.each |$name, $mutator| {
    sensu_mutator { $name:
      * => $mutator,
    }
  }
  $namespaces.each |$name, $namespace| {
    sensu_namespace { $name:
      * => $namespace,
    }
  }
  $oidc_auths.each |$name, $oidc_auth| {
    sensu_oidc_auth { $name:
      * => $oidc_auth,
    }
  }
  $role_bindings.each |$name, $role_binding| {
    sensu_role_binding { $name:
      * => $role_binding,
    }
  }
  $roles.each |$name, $role| {
    sensu_role { $name:
      * => $role,
    }
  }
  $users.each |$name, $user| {
    sensu_user { $name:
      * => $user,
    }
  }
}
