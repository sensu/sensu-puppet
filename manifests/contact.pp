# @summary Manages contact routing
#
# Manage [Contact
# Routing](https://sensuapp.org/docs/latest/enterprise/contact-routing.html)
# configuration with Sensu Enterprise.
#
# Note:  If the `sensu::purge_config` class parameter is `true`, unmanaged
# sensu::contact resources located in /etc/sensu/conf.d/contacts will be purged.
#
# @param ensure Whether the check should be present or not
#
# @param base_path Where to place the contact JSON configuration file.  Defaults to
#   `undef` which defers to the behavior of the underlying sensu_contact type.
#
# @param config The configuration data for the contact.  This is an arbitrary hash to
#   accommodate the various communication channels. For example, `{ "email": {
#   "to": "support@example.com" } }`.
#
define sensu::contact(
  Enum['present','absent'] $ensure = 'present',
  Optional[String] $base_path = undef,
  Hash $config = {},
) {

  $file_ensure = $ensure ? {
    'absent' => 'absent',
    default  => 'file'
  }

  case $::osfamily {
    'windows': {
      $etc_dir   = 'C:/opt/sensu'
      $conf_dir  = "${etc_dir}/conf.d"
      $user      = $::sensu::user
      $group     = $::sensu::group
      $file_mode = undef
    }
    default: {
      $etc_dir   = $::sensu::sensu_etc_dir
      $conf_dir  = "${etc_dir}/conf.d"
      $user      = $::sensu::user
      $group     = $::sensu::group
      $file_mode = '0440'
    }
  }

  # handler configuration may contain "secrets"
  file { "${conf_dir}/contacts/${name}.json":
    ensure => $file_ensure,
    owner  => $user,
    group  => $group,
    mode   => $file_mode,
    before => Sensu_contact[$name],
  }

  sensu_contact { $name:
    ensure    => $ensure,
    config    => $config,
    base_path => $base_path,
    require   => File["${conf_dir}/contacts/${name}.json"],
  }
}
