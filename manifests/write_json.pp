# = Define: sensu::write_json
#
# Writes arbitrary hash data to a config file. Note: you must manually notify
# any Sensu services to restart them when using this defined resource type.
#
# Example:
#
#  sensu::write_json { '/etc/sensu/conf.d/check.json':
#    content => {"config" => {"key" => "value"}},
#    notify  => [
#      Service['sensu-client'],
#      Service['sensu-server'],
#    ],
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
# [*owner*]
#   String. The file owner.
#   Default: $::sensu::user
#
# [*group*]
#   String. The file group.
#   Default: $::sensu::group
#
# [*mode*]
#   String. The file mode.
#   Default: 0755
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
define sensu::write_json (
  Enum['present', 'absent'] $ensure = 'present',
  String                    $owner = 'sensu',
  String                    $group = 'sensu',
  String                    $mode = '0755',
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
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => sensu_sorted_json($content, $pretty),
  }
}
