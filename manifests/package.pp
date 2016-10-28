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
      $pkg_title = 'sensu'
      $pkg_name = 'sensu'
      $pkg_version = $sensu::version
      $pkg_source = undef

      if $sensu::manage_repo {
        class { '::sensu::repo::apt': }
      }
      if $sensu::manage_repo and $sensu::install_repo {
        include ::apt
        $pkg_require = Class['apt::update']
      }
      else {
        $pkg_require = undef
      }
    }

    'RedHat': {
      $pkg_title = 'sensu'
      $pkg_name = 'sensu'
      $pkg_version = $sensu::version
      $pkg_source = undef

      if $sensu::manage_repo {
        class { '::sensu::repo::yum': }
      }

      $pkg_require = undef
    }

    'windows': {
      $repo_require = undef

      $pkg_version = inline_template("<%= scope.lookupvar('sensu::version').sub(/(.*)\\-/, '\\1.') %>")
      $pkg_title = 'Sensu'
      $pkg_name = 'Sensu'
      $pkg_source = "C:\\Windows\\Temp\\sensu-${sensu::version}.msi"
      $pkg_require = "Remote_file[${pkg_source}]"

      remote_file { $pkg_source:
        ensure   => present,
        source   => "http://repositories.sensuapp.org/msi/sensu-${sensu::version}.msi",
        checksum => $::sensu::package_checksum,
      }
    }

    default: { fail("${::osfamily} not supported yet") }

  }

  package { $pkg_title:
    ensure  => $pkg_version,
    name    => $pkg_name,
    source  => $pkg_source,
    require => $pkg_require,
  }

  if $::sensu::sensu_plugin_provider {
    $plugin_provider = $::sensu::sensu_plugin_provider
  } else {
    $plugin_provider = $sensu::use_embedded_ruby ? {
      true    => 'sensu_gem',
      default => 'gem',
    }
  }

  if $plugin_provider =~ /gem/ and $::sensu::gem_install_options {
    package { $::sensu::sensu_plugin_name :
      ensure          => $sensu::sensu_plugin_version,
      provider        => $plugin_provider,
      install_options => $::sensu::gem_install_options,
    }
  } else {
    package { $::sensu::sensu_plugin_name :
      ensure   => $sensu::sensu_plugin_version,
      provider => $plugin_provider,
    }
  }

  if $::osfamily != 'windows' {
    file { '/etc/default/sensu':
      ensure  => file,
      content => template("${module_name}/sensu.erb"),
      owner   => '0',
      group   => '0',
      mode    => '0444',
      require => Package['sensu'],
    }
  }

  file { [ $sensu::conf_dir, "${sensu::conf_dir}/handlers", "${sensu::conf_dir}/checks", "${sensu::conf_dir}/filters", "${sensu::conf_dir}/extensions", "${sensu::conf_dir}/mutators" ]:
    ensure  => directory,
    owner   => $sensu::user,
    group   => $sensu::group,
    mode    => $sensu::dir_mode,
    purge   => $sensu::_purge_config,
    recurse => true,
    force   => true,
    require => Package[$pkg_name],
  }

  if $sensu::manage_handlers_dir {
    file { "${sensu::etc_dir}/handlers":
      ensure  => directory,
      mode    => $sensu::dir_mode,
      owner   => $sensu::user,
      group   => $sensu::group,
      purge   => $sensu::_purge_handlers,
      recurse => true,
      force   => true,
      require => Package[$pkg_name],
    }
  }

  file { ["${sensu::etc_dir}/extensions", "${sensu::etc_dir}/extensions/handlers"]:
    ensure  => directory,
    mode    => $sensu::dir_mode,
    owner   => $sensu::user,
    group   => $sensu::group,
    purge   => $sensu::_purge_extensions,
    recurse => true,
    force   => true,
    require => Package[$pkg_name],
  }

  if $sensu::manage_mutators_dir {
    file { "${sensu::etc_dir}/mutators":
      ensure  => directory,
      mode    => $sensu::dir_mode,
      owner   => $sensu::user,
      group   => $sensu::group,
      purge   => $sensu::_purge_mutators,
      recurse => true,
      force   => true,
      require => Package[$pkg_name],
    }
  }

  if $sensu::_manage_plugins_dir {
    file { "${sensu::etc_dir}/plugins":
      ensure  => directory,
      mode    => $sensu::dir_mode,
      owner   => $sensu::user,
      group   => $sensu::group,
      purge   => $sensu::_purge_plugins,
      recurse => true,
      force   => true,
      require => Package[$pkg_name],
    }
  }

  if $sensu::manage_user {
    user { $sensu::user:
      ensure  => 'present',
      system  => true,
      home    => $sensu::home_dir,
      shell   => $sensu::shell,
      require => Group[$sensu::group],
      comment => 'Sensu Monitoring Framework',
    }

    group { $sensu::group:
      ensure => 'present',
      system => true,
    }
  }

  file { "${sensu::etc_dir}/config.json": ensure => absent }
}
