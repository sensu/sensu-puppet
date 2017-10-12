# @summary Manages Sensu filters
#
# Defines Sensu filters
#
# == Parameters
#
# @param ensure Whether the check should be present or not
#
# @param negate Negate the filter
#
# @param attributes Hash of attributes for the filter
#
# @param when Hash of when entries for the filter
#
define sensu::filter (
  Enum['present','absent'] $ensure = 'present',
  Optional[Boolean] $negate        = undef,
  Optional[Hash] $attributes       = undef,
  Optional[Hash] $when             = undef,
) {

  file { "/etc/sensu/conf.d/filters/${name}.json":
    ensure => $ensure,
    owner  => $::sensu::user,
    group  => $::sensu::group,
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
