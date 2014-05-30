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
        'unstable'  => "http://repos.sensuapp.org/yum-unstable/el/${::operatingsystemmajrelease}/\$basearch/",
        default     => "http://repos.sensuapp.org/yum/el/${::operatingsystemmajrelease}/\$basearch/"
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
  }

}
