#
# Add APT/YUM key and repository based on OS
#
# == Parameters:
#
# $ensure::     'present' or 'absent'
# $repo::       'main' or 'unstable'
#
class sensu::repo (
  $ensure = 'present',
  $repo   = 'main'
  ) {

  case $::operatingsystem {

    'Debian','Ubuntu': {
      class { 'sensu::repo::apt': ensure => $ensure, repo => $repo }
    }

    'Fedora','Rhel','Centos': {
      class { 'sensu::repo::yum': ensure => $ensure, repo => $repo }
    }

    default: { alert("$::operatingsystem not supported yet") }

  }

}
