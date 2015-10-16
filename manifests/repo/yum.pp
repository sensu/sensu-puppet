# = Class: sensu::repo::yum
#
# Adds the Sensu YUM repo support
#
class sensu::repo::yum {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $sensu::install_repo  {
    if $sensu::repo_source {
      $url = $sensu::repo_source
    } else {
      $url = $sensu::repo ? {
        'unstable'  => "http://repositories.sensuapp.org/yum-unstable/\$basearch/",
        default     => "http://repositories.sensuapp.org/yum/\$basearch/"
      }
    }

    yumrepo { 'sensu':
      enabled  => 1,
      baseurl  => $url,
      gpgcheck => 0,
      name     => 'sensu',
      descr    => 'sensu',
      before   => Package['sensu'],
    }

    # prep for Enterprise repos
    $se_user = $sensu::enterprise_user
    $se_pass = $sensu::enterprise_pass

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
