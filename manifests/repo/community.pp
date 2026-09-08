# @summary Private class to manage sensu community repository resources
# @api private
#
class sensu::repo::community {

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
    yumrepo { 'sensu_community':
      ensure          => 'present',
      baseurl         => "https://packagecloud.io/sensu/community/el/${repo_release}/\$basearch",
      descr           => 'sensu_community',
      enabled         => 1,
      gpgcheck        => 0,
      gpgkey          => 'https://packagecloud.io/sensu/community/gpgkey',
      metadata_expire => 300,
      repo_gpgcheck   => 1,
      sslcacert       => '/etc/pki/tls/certs/ca-bundle.crt',
      sslverify       => 1,
    }
    if String($repo_release) == '8' {
      # This exec ensures GPG key is added without errors
      # Initial GPG download for dnf appears to return no exit code, tries=2 is workaround
      # This is method used by upstream Package Cloud scripts and will download GPG key
      # https://packagecloud.io/sensu/stable/install#bash-rpm
      exec { 'dnf makecache sensu_community':
        path        => '/usr/bin:/bin:/usr/sbin:/sbin',
        command     => "dnf -q makecache -y --disablerepo='*' --enablerepo='sensu_community'",
        refreshonly => true,
        tries       => 2,
        subscribe   => Yumrepo['sensu_community'],
      }
    }
  }
  if $facts['os']['family'] == 'Debian' {
    apt::source { 'sensu_community':
      ensure   => 'present',
      location => "https://packagecloud.io/sensu/community/${downcase($facts['os']['name'])}/",
      repos    => 'main',
      release  => $facts['os']['distro']['codename'],
      include  => {
        'src' => true,
      },
      key      => {
        'id'     => '7F54E8A5C0CB51DBE612D2F50156BD72FEC8CD59',
        'source' => 'https://packagecloud.io/sensu/community/gpgkey',
      },
    }
  }
}
