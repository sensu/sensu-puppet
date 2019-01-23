# @summary Adds the Sensu YUM repo support
#
# Adds the Sensu YUM repo support
#
class sensu::repo::yum {

  if $::sensu::install_repo  {
    if $::sensu::repo_source {
      $url = $::sensu::repo_source
    } else {
      if $::operatingsystem == 'Amazon' {
        if $facts['os']['release']['major'] =~ /^201\d$/ {
          $releasever = '6'
        } else {
          $releasever = '7'
        }
      } else {
        $releasever = '$releasever'
      }
      $url = $::sensu::repo ? {
        'unstable'  => "https://sensu.global.ssl.fastly.net/yum-unstable/${releasever}/\$basearch/",
        default     => "https://sensu.global.ssl.fastly.net/yum/${releasever}/\$basearch/"
      }
    }

    yumrepo { 'sensu':
      enabled  => 1,
      baseurl  => $url,
      gpgcheck => 0,
      name     => 'sensu',
      descr    => 'sensu',
      before   => Package[$sensu::package::pkg_title],
    }

    # prep for Enterprise repos
    $se_user = $::sensu::enterprise_user
    $se_pass = $::sensu::enterprise_pass

    if $::sensu::enterprise {
      $se_url  = "http://${se_user}:${se_pass}@enterprise.sensuapp.com/yum/noarch/"

      yumrepo { 'sensu-enterprise':
        enabled  => 1,
        baseurl  => $se_url,
        gpgcheck => 0,
        name     => 'sensu-enterprise',
        descr    => 'sensu-enterprise',
        before   => Package['sensu-enterprise'],
      }
    }

    if $::sensu::enterprise_dashboard {
      $dashboard_url = "http://${se_user}:${se_pass}@enterprise.sensuapp.com/yum/\$basearch/"

      yumrepo { 'sensu-enterprise-dashboard':
        enabled  => 1,
        baseurl  => $dashboard_url,
        gpgcheck => 0,
        name     => 'sensu-enterprise-dashboard',
        descr    => 'sensu-enterprise-dashboard',
        before   => Package['sensu-enterprise-dashboard'],
      }
    }
  }
}
