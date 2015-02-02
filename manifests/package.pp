# = Class: sensu::package
#
# Installs the Sensu packages
#
class sensu::package {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  case $::osfamily {

    'Debian': {
      class { 'sensu::repo::apt': }
      if $sensu::install_repo {
        $repo_require = Apt::Source['sensu']
      } else {
        $repo_require = undef
      }
    }

    'RedHat': {
      class { 'sensu::repo::yum': }
      if $sensu::install_repo {
        $repo_require = Yumrepo['sensu']
      } else {
        $repo_require = undef
      }
    }

    default: { fail("${::osfamily} not supported yet") }

  }

  package { 'sensu':
    ensure  => $sensu::version,
  }

  if $::sensu::sensu_plugin_provider {
    $plugin_provider = $::sensu::sensu_plugin_provider
  } else {
    $plugin_provider = $sensu::use_embedded_ruby ? {
      true    => 'sensu_gem',
      default => 'gem',
    }
  }

  package { $::sensu::sensu_plugin_name :
    ensure   => $sensu::sensu_plugin_version,
    provider => $plugin_provider,
  }

  file { '/etc/default/sensu':
    ensure  => file,
    content => template("${module_name}/sensu.erb"),
    owner   => '0',
    group   => '0',
    mode    => '0444',
    require => Package['sensu'],
  }

  file { [ '/etc/sensu/conf.d', '/etc/sensu/conf.d/handlers', '/etc/sensu/conf.d/checks', '/etc/sensu/conf.d/filters', '/etc/sensu/conf.d/extensions' ]:
    ensure  => directory,
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0555',
    purge   => $sensu::purge_config,
    recurse => true,
    force   => true,
    require => Package['sensu'],
  }

  file { ['/etc/sensu/handlers', '/etc/sensu/extensions', '/etc/sensu/mutators', '/etc/sensu/extensions/handlers']:
    ensure  => directory,
    mode    => '0555',
    owner   => 'sensu',
    group   => 'sensu',
    require => Package['sensu'],
  }

  if $sensu::_manage_plugins_dir {
    file { '/etc/sensu/plugins':
      ensure  => directory,
      mode    => '0555',
      owner   => 'sensu',
      group   => 'sensu',
      require => Package['sensu'],
    }
  }

  if $sensu::manage_user {
    user { 'sensu':
      ensure  => 'present',
      system  => true,
      home    => '/opt/sensu',
      shell   => '/bin/false',
      comment => 'Sensu Monitoring Framework',
    }

    group { 'sensu':
      ensure => 'present',
      system => true,
    }
  }

  file { '/etc/sensu/config.json': ensure => absent }
}
