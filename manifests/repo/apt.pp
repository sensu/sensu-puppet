class sensu::repo::apt (
    $ensure,
    $repo
  ) {

  if defined?() {
    apt::key { 'Sensu':
      ensure  => $ensure,
      url     => 'http://repos.sensuapp.org/apt/pubkey.gpg',
    }
    apt::source { 'sensuapp':
      ensure  => $ensure,
      content => "deb http://repos.sensuapp.org/apt sensu ${repo}",
      require => Apt::Key['Sensu'],
    }
  } else {
    fail (' notice message ')
  }

}
