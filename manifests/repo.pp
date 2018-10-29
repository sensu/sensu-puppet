# private class
class sensu::repo {

  case $facts['os']['family'] {
    'RedHat': {
      if $facts['os']['name'] == 'Amazon' {
        if $facts['os']['release']['major'] =~ /^201\d$/ {
          $repo_release = '6'
        } else {
          $repo_release = '7'
        }
      } else {
        $repo_release = $facts['os']['release']['major']
      }
      # TODO: change from beta to stable once there are stable releases
      yumrepo { 'sensu':
        descr           => 'sensu',
        baseurl         => "https://packagecloud.io/sensu/beta/el/${repo_release}/\$basearch",
        repo_gpgcheck   => 1,
        gpgcheck        => 0,
        enabled         => 1,
        gpgkey          => 'https://packagecloud.io/sensu/beta/gpgkey',
        sslverify       => 1,
        sslcacert       => '/etc/pki/tls/certs/ca-bundle.crt',
        metadata_expire => 300,
      }
    }
    'Debian': {
      #TODO: change from beta to stable once there are stable releases
      apt::source { 'sensu':
        ensure   => 'present',
        location => "https://packagecloud.io/sensu/beta/${downcase($facts['os']['name'])}/",
        repos    => 'main',
        release  => $facts['os']['distro']['codename'],
        include  => {
          'src' => true,
        },
        key      => {
          'id'     => '0B3B86AFEF2D99B085BEDC6A4263180AAE8AAE03',
          'source' => 'https://packagecloud.io/sensu/beta/gpgkey',
        },
      }
    }
    default: {
      # do nothing
    }
  }
}

