# = Class: sensu::repo::yum
#
# Adds Sensu YUM repo support
#
# == Parameters
#

class sensu::repo::yum (
    $ensure = 'present'
  ) {

  $enabled = $ensure ? {
    'present' => 1,
    default   => 'absent'
  }

  yumrepo { 'sensu':
    enabled  => $enabled,
    baseurl  => 'http://repos.sensuapp.org/yum/el/$releasever/$basearch/',
    gpgcheck => 0,
    name     => 'sensu',
    before   => Package['sensu'],
  }

}
