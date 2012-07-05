#
# Add APT key and repository
#
# == Parameters:
#
# $ensure::     'present' or 'absent'
# $repo::       'main' or 'unstable'
#
class sensu::debian (
  $ensure = 'present',
  $repo   = 'main'
  ) {

  sensu::apt::key { 'Sensu':
    ensure  => 'present',
    url     => 'http://repos.sensuapp.org/apt/pubkey.gpg',
  }

  sensu::apt::source { 'sensuapp':
    ensure  => $ensure,
    content => "deb http://repos.sensuapp.org/apt sensu ${repo}",
    require => Sensu::Apt::Key['Sensu'],
  }

}
