class sensu::repo::apt (
    $ensure,
    $repo
  ) {

  if defined(apt::source) and defined(apt::key) {

    apt::source { 'sensu':
      ensure      => $ensure,
      location    => 'http://repos.sensuapp.org/apt',
      release     => 'sensu',
      repos       => $repo,
      include_src => false,
      before      => Package['sensu'],
    }

    apt::key { 'sensu':
      key         => '7580C77F',
      key_source  => 'http://repos.sensuapp.org/apt/pubkey.gpg',
    }

  } else { fail('This class requires puppet-apt module') }

}
