# = Define: sensu::filter
#
# Defines Sensu filters
#
# == Parameters
#
# [*ensure*]
#   String. Whether the check should be present or not
#   Default: present
#   Valid values: present, absent
#
# [*negate*]
#   Boolean.  Negate the filter
#   Default: undef
#   Valid values: true, false
#
# [*attributes*]
#   Hash.  Hash of attributes for the filter
#   Default: undef
#
define sensu::filter (
  Enum['present','absent'] $ensure = 'present',
  Optional[Boolean] $negate        = undef,
  Optional[Hash] $attributes       = undef,
  Optional[Hash] $when             = undef,
) {

  file { "/etc/sensu/conf.d/filters/${name}.json":
    ensure => $ensure,
    owner  => 'sensu',
    group  => 'sensu',
    mode   => '0444',
  }

  sensu_filter { $name:
    ensure     => $ensure,
    negate     => $negate,
    attributes => $attributes,
    when       => $when,
    require    => File['/etc/sensu/conf.d/filters'],
  }

}
