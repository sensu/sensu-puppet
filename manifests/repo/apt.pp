# = Class: sensu::repo::apt
#
# Adds the Sensu repo to Apt
#
# == Parameters
#
class sensu::repo::apt {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if defined(apt::source) {

    $ensure = $sensu::install_repo ? {
      true    => 'present',
      default => 'absent'
    }

    if $sensu::repo_source {
      $url = $sensu::repo_source
    } else {
      $url = 'http://repos.sensuapp.org/apt'
    }

    apt::source { 'sensu':
      ensure      => $ensure,
      location    => $url,
      release     => 'sensu',
      repos       => $sensu::repo,
      include_src => false,
      key         => $sensu::repo_key_id,
      key_source  => $sensu::repo_key_source,
      before      => Package['sensu'],
    }

  } else {
    fail('This class requires puppet-apt module')
  }

}
