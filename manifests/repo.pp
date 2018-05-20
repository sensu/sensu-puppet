# private class
class sensu::repo {

  case $::facts['osfamily'] {
    'RedHat': {
      # TODO: change from nightly to stable once there are stable releases
      yumrepo { 'sensu_nightly':
        baseurl         => "https://packagecloud.io/sensu/nightly/el/${::operatingsystemmajrelease}/\$basearch",
        repo_gpgcheck   => 1,
        gpgcheck        => 0,
        enabled         => 1,
        gpgkey          => 'https://packagecloud.io/sensu/nightly/gpgkey',
        sslverify       => 1,
        sslcacert       => '/etc/pki/tls/certs/ca-bundle.crt',
        metadata_expire => 300,
      }
    }
    default: {
      # do nothing
    }
  }
}

