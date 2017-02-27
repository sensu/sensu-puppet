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
      $url = 'http://repositories.sensuapp.org/apt'
    }

    apt::source { 'sensu':
      ensure   => $ensure,
      location => $url,
      release  => $::lsbdistcodename,
      repos    => $sensu::repo,
      include  => {
        'src' => false,
      },
      key      => {
        'id'     => $sensu::repo_key_id,
        'source' => $sensu::repo_key_source,
      },
      before   => Package['sensu'],
      notify   => Exec['apt-update'],
    }

    exec {
      'apt-update':
        refreshonly  => true,
        command      => '/usr/bin/apt-get update';
    }

    if $sensu::enterprise {
      $se_user = $sensu::enterprise_user
      $se_pass = $sensu::enterprise_pass
      $se_url  = "http://${se_user}:${se_pass}@enterprise.sensuapp.com/apt"
      $include = { 'src' => false, }
      $key     = {
        'id'      => $sensu::enterprise_repo_key_id,
        # TODO: this is not ideal, but the apt module doesn't currently support
        # HTTP auth for the source URI
        'content' => template('sensu/pubkey.gpg'),
      }

      apt::source { 'sensu-enterprise':
        ensure   => $ensure,
        location => $se_url,
        release  => 'sensu-enterprise',
        repos    => $sensu::repo,
        include  => $include,
        key      => $key,
        before   => Package['sensu-enterprise'],
      }
    }

  } else {
    fail('This class requires puppetlabs-apt module')
  }

}
