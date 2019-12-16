# @summary Define sensu resources
# @api private
#
class sensu::backend::resources {
  include sensu::backend
  $sensu::backend::ad_auths.each |$name, $ad_auth| {
    sensu_ad_auth { $name:
      * => $ad_auth,
    }
  }
  $sensu::backend::assets.each |$name, $asset| {
    sensu_asset { $name:
      * => $asset,
    }
  }
  $sensu::backend::bonsai_assets.each |$name, $bonsai_asset| {
    sensu_bonsai_asset { $name:
      * => $bonsai_asset,
    }
  }
  $sensu::backend::checks.each |$name, $check| {
    sensu_check { $name:
      * => $check,
    }
  }
    $sensu::backend::cluster_members.each |$name, $cluster_member| {
    sensu_cluster_member { $name:
      * => $cluster_member,
    }
  }
  $sensu::backend::cluster_role_bindings.each |$name, $cluster_role_binding| {
    sensu_cluster_role_binding { $name:
      * => $cluster_role_binding,
    }
  }
  $sensu::backend::cluster_roles.each |$name, $cluster_role| {
    sensu_cluster_role { $name:
      * => $cluster_role,
    }
  }
  $sensu::backend::entities.each |$name, $entity| {
    sensu_entity { $name:
      * => $entity,
    }
  }
  $sensu::backend::etcd_replicators.each |$name, $etcd_replicator| {
    sensu_etcd_replicator { $name:
      * => $etcd_replicator,
    }
  }
  $sensu::backend::filters.each |$name, $filter| {
    sensu_filter { $name:
      * => $filter,
    }
  }
  $sensu::backend::handlers.each |$name, $handler| {
    sensu_handler { $name:
      * => $handler,
    }
  }
  $sensu::backend::hooks.each |$name, $hook| {
    sensu_hook { $name:
      * => $hook,
    }
  }
  $sensu::backend::ldap_auths.each |$name, $ldap_auth| {
    sensu_ldap_auth { $name:
      * => $ldap_auth,
    }
  }
  $sensu::backend::mutators.each |$name, $mutator| {
    sensu_mutator { $name:
      * => $mutator,
    }
  }
  $sensu::backend::namespaces.each |$name, $namespace| {
    sensu_namespace { $name:
      * => $namespace,
    }
  }
  $sensu::backend::oidc_auths.each |$name, $oidc_auth| {
    sensu_oidc_auth { $name:
      * => $oidc_auth,
    }
  }
  $sensu::backend::role_bindings.each |$name, $role_binding| {
    sensu_role_binding { $name:
      * => $role_binding,
    }
  }
  $sensu::backend::roles.each |$name, $role| {
    sensu_role { $name:
      * => $role,
    }
  }
  $sensu::backend::users.each |$name, $user| {
    sensu_user { $name:
      * => $user,
    }
  }
}
