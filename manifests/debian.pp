
class sensu::debian {

  sensu::apt::key { 'sensuapp':
    ensure  => 'present',
    url     => 'http://repos.sensuapp.org/apt/pubkey.gpg',
  }

  sensu::apt::source { 'sensuapp':
    ensure  => 'present',
    content => 'deb http://repos.sensuapp.org/apt sensu main',
    require => Sensu::Apt::Key['sensuapp'],
  }

}
