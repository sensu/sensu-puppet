# = Define: sensu::routing
#
# Manage [Contact
# Routing](https://sensuapp.org/docs/latest/enterprise/contact-routing.html)
# configuration with Sensu Enterprise.
#
# Note:  If the `sensu::purge_config` class parameter is `true`, unmanaged
# sensu::contact resources located in /etc/sensu/conf.d/contacts will be purged.
#
# == Parameters
#
# [*ensure*]
#   String. Whether the check should be present or not
#   Default: present
#   Valid values: present, absent
#
# [*base_path*]
#   String.  Where to place the contact JSON configuration file.  Defaults to
#   `undef` which defers to the behavior of the underlying sensu_contact type.
#   Default: undef
#
# [*config*]
#   Hash. The configuration data for the contact.  This is an arbitrary hash to
#   accommodate the various communication channels. For example, `{ "email": {
#   "to": "support@example.com" } }`.
#   Default: {}
define sensu::contact(
  Enum['present','absent'] $ensure = 'present',
  Optional[String] $base_path = undef,
  Hash $config = {},
) {

  $file_ensure = $ensure ? {
    'absent' => 'absent',
    default  => 'file'
  }

  # handler configuration may contain "secrets"
  file { "/etc/sensu/conf.d/contacts/${name}.json":
    ensure => $file_ensure,
    owner  => 'sensu',
    group  => 'sensu',
    mode   => '0440',
    before => Sensu_contact[$name],
  }

  sensu_contact { $name:
    ensure    => $ensure,
    config    => $config,
    base_path => $base_path,
    require   => File['/etc/sensu/conf.d/contacts'],
  }
}
