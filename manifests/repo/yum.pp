class sensu::repo::yum (
    $ensure,
    $repo
  ) {

  $enabled = $ensure ? {
    'present' => 1,
    default   => 'absent'
  }

  yumrepo { 'sensu':
    enabled  => $enabled,
    baseurl  => 'http://repos.sensuapp.org/yum/el/$releasever/$basearch/',
    gpgcheck => 0,
    name     => "sensu-${repo}",
  }

}
