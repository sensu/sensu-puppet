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

  include ::sensu

  $file_ensure = $ensure ? {
    'absent' => 'absent',
    default  => 'file'
  }

  # handler configuration may contain "secrets"
  file { "${::sensu::conf_dir}/contacts/${name}.json":
    ensure => $file_ensure,
    owner  => $::sensu::user,
    group  => $::sensu::group,
    mode   => $::sensu::config_file_mode,
    before => Sensu_contact[$name],
  }

  sensu_contact { $name:
    ensure    => $ensure,
    config    => $config,
    base_path => $base_path,
    require   => File["${::sensu::conf_dir}/contacts/${name}.json"],
  }
}
