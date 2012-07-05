#
# Add/remove an apt key
#
# == Parameters:
#
# $title::      The key id
# $ensure::     "present" or "absent"
# $url::        The url of the key
# $server::     The server from which download the key
#               url or server are required on ensure is "present"
#
define sensu::apt::key($ensure, $url = '', $server = '') {

    case $ensure {

        'present': {

            if $url != '' {
                exec { "apt-key_present_$title":
                    command     => "/usr/bin/wget -O- -q '${url}' | /usr/bin/apt-key add -",
                    unless      => "/usr/bin/apt-key list | /bin/grep -c '$title'",
                }
            } else {
                exec { "apt-key_present_$title":
                    command     => "/usr/bin/apt-key adv --keyserver '${server}' --recv '${title}'",
                    unless      => "/usr/bin/apt-key list | /bin/grep -c '$title'",
                }
            }

        }

        'absent': {

            exec { "apt-key_absent_$title":
                command     => "/usr/bin/apt-key del '$title'",
                onlyif      => "/usr/bin/apt-key list | /bin/grep -c '$title'",
            }

        }

        default: {
            fail "Invalid 'ensure' value '$ensure' for apt::key"
        }
    }
}
