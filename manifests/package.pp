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
      $pkg_version = $::sensu::version
      $pkg_source = undef

      if $::sensu::manage_repo {
        class { '::sensu::repo::apt': }
      }
      if $::sensu::manage_repo and $::sensu::install_repo {
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
      $pkg_version = $::sensu::version
      $pkg_source = undef

      if $::sensu::manage_repo {
        class { '::sensu::repo::yum': }
      }

      $pkg_require = undef
    }

    'windows': {
      $repo_require = undef

      $pkg_version = $::sensu::version
      # Download the latest published version
      $pkg_url_version = $pkg_version ? {
        'installed' => 'latest',
        default   => $pkg_version,
      }
      $pkg_title = 'sensu'
      $pkg_name = 'sensu'
      $pkg_source = "C:\\Windows\\Temp\\sensu-${pkg_url_version}.msi"
      $pkg_require = "Remote_file[${pkg_name}]"
      # The OS Release specific sub-folder
      $os_release = $facts['os']['release']['major']
      $pkg_url_dir = $os_release ? {
        '2008 R2' => '2008r2',
        '2012 R2' => '2012r2',
        '2016 R2' => '2016r2',
        default   => $os_release,
      }
      $pkg_arch = $facts['os']['architecture']

      remote_file { $pkg_name:
        ensure   => present,
        path     => $pkg_source,
        source   => "${sensu::windows_repo_prefix}/${pkg_url_dir}/sensu-${pkg_url_version}-${pkg_arch}.msi",
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
    $plugin_provider = $::sensu::use_embedded_ruby ? {
      true    => 'sensu_gem',
      default => 'gem',
    }
  }

  if $plugin_provider =~ /gem/ and $::sensu::gem_install_options {
    package { $::sensu::sensu_plugin_name :
      ensure          => $::sensu::sensu_plugin_version,
      provider        => $plugin_provider,
      install_options => $::sensu::gem_install_options,
    }
  } else {
    package { $::sensu::sensu_plugin_name :
      ensure   => $::sensu::sensu_plugin_version,
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
      require => Package[$pkg_title],
    }
  }

  file { [ $::sensu::conf_dir, "${sensu::conf_dir}/handlers", "${sensu::conf_dir}/checks", "${sensu::conf_dir}/filters", "${sensu::conf_dir}/extensions", "${sensu::conf_dir}/mutators" ]:
    ensure  => directory,
    owner   => $::sensu::user,
    group   => $::sensu::group,
    mode    => $::sensu::dir_mode,
    purge   => $::sensu::_purge_config,
    recurse => true,
    force   => true,
    require => Package[$pkg_title],
  }

  if $::sensu::manage_handlers_dir {
    file { "${sensu::etc_dir}/handlers":
      ensure  => directory,
      mode    => $::sensu::dir_mode,
      owner   => $::sensu::user,
      group   => $::sensu::group,
      purge   => $::sensu::_purge_handlers,
      recurse => true,
      force   => true,
      require => Package[$pkg_title],
    }
  }

  file { ["${sensu::etc_dir}/extensions", "${sensu::etc_dir}/extensions/handlers"]:
    ensure  => directory,
    mode    => $::sensu::dir_mode,
    owner   => $::sensu::user,
    group   => $::sensu::group,
    purge   => $::sensu::_purge_extensions,
    recurse => true,
    force   => true,
    require => Package[$pkg_title],
  }

  if $::sensu::manage_mutators_dir {
    file { "${sensu::etc_dir}/mutators":
      ensure  => directory,
      mode    => $::sensu::dir_mode,
      owner   => $::sensu::user,
      group   => $::sensu::group,
      purge   => $::sensu::_purge_mutators,
      recurse => true,
      force   => true,
      require => Package[$pkg_title],
    }
  }

  if $::sensu::_manage_plugins_dir {
    file { "${sensu::etc_dir}/plugins":
      ensure  => directory,
      mode    => $::sensu::dir_mode,
      owner   => $::sensu::user,
      group   => $::sensu::group,
      purge   => $::sensu::_purge_plugins,
      recurse => true,
      force   => true,
      require => Package[$pkg_title],
    }
  }

  if $::sensu::manage_user and $::osfamily != 'windows' {
    user { $::sensu::user:
      ensure  => 'present',
      system  => true,
      home    => $::sensu::home_dir,
      shell   => $::sensu::shell,
      require => Group[$::sensu::group],
      comment => 'Sensu Monitoring Framework',
    }

    group { $::sensu::group:
      ensure => 'present',
      system => true,
    }
  } elsif $::sensu::manage_user and $::osfamily == 'windows' {
    notice('Managing a local windows user is not implemented on windows')
  }

  file { "${sensu::etc_dir}/config.json": ensure => absent }
}
