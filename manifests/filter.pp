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
  $ensure     = 'present',
  $negate     = undef,
  $attributes = undef,
) {

  validate_re($ensure, ['^present$', '^absent$'] )
  if $negate {
    validate_bool($negate)
  }

  if $attributes and !is_hash($attributes) {
    fail('attributes must be a hash')
  }

  file { "/etc/sensu/conf.d/filters/${name}.json":
    ensure  => $ensure,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0444',
  }

  sensu_filter { $name:
    ensure      => $ensure,
    negate      => $negate,
    attributes  => $attributes,
  }

}
