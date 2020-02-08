# @summary Private class to manage sensu repository resources
# @api private
#
class sensu::repo {

  if $facts['os']['family'] == 'RedHat' {
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
    if String($repo_release) == '8' {
      # This exec ensures GPG key is added without errors
      # Initial GPG download for dnf appears to return no exit code, tries=2 is workaround
      # This is method used by upstream Package Cloud scripts and will download GPG key
      # https://packagecloud.io/sensu/stable/install#bash-rpm
      exec { 'dnf makecache sensu':
        path        => '/usr/bin:/bin:/usr/sbin:/sbin',
        command     => "dnf -q makecache -y --disablerepo='*' --enablerepo='sensu'",
        refreshonly => true,
        tries       => 2,
        subscribe   => Yumrepo['sensu'],
      }
    }
  }
  if $facts['os']['family'] == 'Debian' {
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
}
