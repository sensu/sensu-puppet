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

  if defined(apt::source) and defined(apt::key) {

    $ensure = $sensu::install_repo_real ? {
      true    => 'present',
      default => 'absent'
    }

    apt::source { 'sensu':
      ensure      => $ensure,
      location    => 'http://repos.sensuapp.org/apt',
      release     => 'sensu',
      repos       => $sensu::repo,
      include_src => false,
      before      => Package['sensu'],
    }

    apt::key { 'sensu':
      key         => '7580C77F',
      key_source  => 'http://repos.sensuapp.org/apt/pubkey.gpg',
    }

  } else {
    fail('This class requires puppet-apt module')
  }

}
