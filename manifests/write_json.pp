# = Define: sensu::write_json
#
# Writes arbitrary hash data to a config file. Note: you must manually notify
# any Sensu services to restart them when using this defined resource type.
#
# Example:
#
#  sensu::write_json{'/etc/sensu/conf.d/check.json':
#    content => {"config" => {"key" => "value"}},
#    notify  => [Service['sensu-client'], Service['sensu-server']],
#  }
#
# == Parameters
#
# [*name*]
#   String. The config file target path.
#
# [*ensure*]
#   String. Whether the file should be present or not.
#   Default: present
#   Valid values: present, absent
#
# [*mode*]
#   String. The file mode.
#   Default: 0755
#
# [*owner*]
#   String. The file owner.
#   Default: $sensu::user
#
# [*group*]
#   String. The file group.
#   Default: $sensu::group
#
# [*pretty*]
#   Boolean. Write the json with "pretty" indenting & formating.
#   Default: true
#
# [*content*]
#   Hash. The hash content that will be converted to json and written into
#         the target config file.
#   Default: {}
#
define sensu::write_json(
  Enum['present', 'absent'] $ensure = 'present',
  String                    $mode = '0755',
  String                    $owner = $sensu::owner,
  String                    $group = $sensu::group,
  Boolean                   $pretty = true,
  Hash                      $content = {},
) {

  # ensure we have a properly formatted file path for our target OS
  case $::kernel {
    'windows': {
      assert_type(Stdlib::Windowspath, $title)
    }
    default: {
      assert_type(Stdlib::Unixpath, $title)
    }
  }

  # Write the config file, using the native file resource and the
  # sensu_sorted_json function to format/sort the json.
  file { $title :
    ensure  => $ensure,
    mode    => $mode,
    owner   => $owner,
    group   => $group,
    content => sensu_sorted_json($content, $pretty, 4),
  }
}
