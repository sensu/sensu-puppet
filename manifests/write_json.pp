# @summary Writes arbitrary hash data to a config file.
#
# Writes arbitrary hash data to a config file. Note: you must manually notify
# any Sensu services to restart them when using this defined resource type.
#
# @example
#  sensu::write_json { '/etc/sensu/conf.d/check.json':
#    content => {"config" => {"key" => "value"}},
#    notify  => [
#      Service['sensu-client'],
#      Service['sensu-server'],
#    ],
#  }
#
# @param ensure Whether the file should be present or not.
#
# @param owner The file owner.
#
# @param group The file group.
#
# @param mode The file mode.
#
# @param pretty Write the json with "pretty" indenting & formating.
#
# @param content The hash content that will be converted to json
#   and written into the target config file.
#
# [*notify_list*]
#   Array. A listing of resources to notify upon changes to the target JSON
#          file.
#   Default: []
define sensu::write_json (
  Enum['present', 'absent'] $ensure = 'present',
  String                    $owner = 'sensu',
  String                    $group = 'sensu',
  String                    $mode = '0775',
  Boolean                   $pretty = true,
  Hash                      $content = {},
  Array[Variant[Data,Type]] $notify_list = [],
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
    notify  => $notify_list,
  }
}
