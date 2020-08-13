# @summary Sensu class for common user resources
# @api private
#
class sensu::common::user {
  include sensu

  if $sensu::manage_user and $sensu::sensu_user {
    user { 'sensu':
      ensure     => 'present',
      name       => $sensu::sensu_user,
      forcelocal => true,
      shell      => '/bin/false',
      gid        => $sensu::sensu_group,
      uid        => undef,
      home       => '/var/lib/sensu',
      managehome => false,
      system     => true,
    }
  }
  if $sensu::manage_group and $sensu::sensu_group {
    group { 'sensu':
      ensure     => 'present',
      name       => $sensu::sensu_group,
      forcelocal => true,
      gid        => undef,
      system     => true,
    }
  }
}
