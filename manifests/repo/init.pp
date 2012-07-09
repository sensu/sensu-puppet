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

    'debian|ubuntu': {
      class { 'sensu::repo::apt': ensure => $ensure, repo => $repo }
    }

    'fedora|rhel|centos': {
      class { 'sensu::repo::yum': ensure => $ensure, repo => $repo }
    }

    default: { notify message }

  }

}
