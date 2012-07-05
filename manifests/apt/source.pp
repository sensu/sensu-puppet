
#
# Add/remove a source
#
# == Parameters:
#
# $title::      The source name
# $ensure::     "present" or "absent"
# $content::    The content to add to source.list
#
define sensu::apt::source($ensure, $content = '') {

    $filepath = "/etc/apt/sources.list.d/${title}.list"

    case $ensure {

        'present': {

            file { "add_apt_source_$filepath":
                path        => $filepath,
                content     => $content
            }

            exec { "update_apt_source_$filepath":
                command     => '/usr/bin/apt-get update',
                subscribe   => File["add_apt_source_$filepath"],
                refreshonly => true
            }

        }

        'absent': {

            file { $filepath:
                ensure      => absent
            }
        }

        default: {
            fail "Invalid 'ensure' value '$ensure' for apt::source"
        }
    }
}
