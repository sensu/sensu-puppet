# @summary Private class to manage sensu repository resources
# @api private
#
class sensu::repo (
  $manage_repo = $sensu::manage_repo
) inherits sensu {

  if any2bool($manage_repo) {
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
        yumrepo { 'sensu':
          descr           => 'sensu',
          baseurl         => "https://packagecloud.io/sensu/stable/el/${repo_release}/\$basearch",
          repo_gpgcheck   => 1,
          gpgcheck        => 0,
          enabled         => 1,
          gpgkey          => 'https://packagecloud.io/sensu/stable/gpgkey',
          sslverify       => 1,
          sslcacert       => '/etc/pki/tls/certs/ca-bundle.crt',
          metadata_expire => 300,
        }
      }
      'Debian': {
        apt::source { 'sensu':
          ensure   => 'present',
          location => "https://packagecloud.io/sensu/stable/${downcase($facts['os']['name'])}/",
          repos    => 'main',
          release  => $facts['os']['distro']['codename'],
          include  => {
            'src' => true,
          },
          key      => {
            'id'     => 'CB1605C4E988C91F438249E3A5BC3FB70A3F7426',
            'source' => 'https://packagecloud.io/sensu/stable/gpgkey',
          },
        }
      }
      default: {
        # do nothing
      }
    }
  }
}

