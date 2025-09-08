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
    
    # For Rocky Linux 8 and similar EL8 distributions, use the official installation script
    if String($repo_release) == '8' {
      # Ensure curl is installed
      package { 'curl':
        ensure => 'installed',
      }
      
      exec { 'install sensu repository':
        path        => '/usr/bin:/bin:/usr/sbin:/sbin',
        command     => 'curl -s https://packagecloud.io/install/repositories/sensu/stable/script.rpm.sh | bash',
        unless      => 'dnf repolist | grep -q sensu',
        require     => Package['curl'],
      }
      
                # Configure the repository to disable GPG checking for packages
          # Use exec to replace all gpgcheck=1 with gpgcheck=0
          exec { 'disable sensu gpg check':
            path        => '/usr/bin:/bin:/usr/sbin:/sbin',
            command     => 'sed -i "s/gpgcheck=1/gpgcheck=0/g" /etc/yum.repos.d/sensu_stable.repo',
            unless      => 'grep -q "gpgcheck=0" /etc/yum.repos.d/sensu_stable.repo',
            require     => Exec['install sensu repository'],
            notify      => Exec['refresh sensu repository cache'],
          }
      
      # Refresh repository cache after disabling GPG check
      exec { 'refresh sensu repository cache':
        path        => '/usr/bin:/bin:/usr/sbin:/sbin',
        command     => 'dnf makecache',
        refreshonly => true,
      }
    } else {
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
