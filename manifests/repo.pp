# private class
class sensu::repo {

  case $facts['os']['family'] {
    'RedHat': {
      # TODO: change from nightly to stable once there are stable releases
      yumrepo { 'sensu_nightly':
        baseurl         => "https://packagecloud.io/sensu/nightly/el/${facts['os']['release']['major']}/\$basearch",
        repo_gpgcheck   => 1,
        gpgcheck        => 0,
        enabled         => 1,
        gpgkey          => 'https://packagecloud.io/sensu/nightly/gpgkey',
        sslverify       => 1,
        sslcacert       => '/etc/pki/tls/certs/ca-bundle.crt',
        metadata_expire => 300,
      }
    }
    'Debian': {
      #TODO: change from nightly to stable once there are stable releases
      apt::source { 'sensu_nightly':
        ensure   => 'present',
        location => "https://packagecloud.io/sensu/nightly/${downcase($facts['os']['name'])}/",
        repos    => 'main',
        release  => $facts['os']['distro']['codename'],
        include  => {
          'src' => true,
        },
        key      => {
          'id'     => 'EB17E7F42AD4720A6679044309F9A5D85A56B390',
          'source' => 'https://packagecloud.io/sensu/nightly/gpgkey',
        },
      }
    }
    default: {
      # do nothing
    }
  }
}

