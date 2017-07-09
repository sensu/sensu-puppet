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
      $default_dir = '/etc/default'
      $pkg_title = 'sensu'
      $pkg_name = 'sensu'
      $pkg_version = $::sensu::version
      $pkg_source = undef
      $pkg_provider = undef

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
    'FreeBSD': {
      $default_dir = '/usr/local/etc/default'
      $pkg_title = 'sensu'
      $pkg_name = 'sensu'
      $pkg_version = template('sensu/sensu-freebsd-package-version.erb')
      $pkg_provider = undef
      $pkg_url_version = $::sensu::version ? {
        'installed' => 'latest',
        # This template translates '-' to '_' in $::sensu::version.
        default     => template('sensu/sensu-freebsd-package-version.erb'),
      }

      if $::sensu::pkg_url == undef {
        $_pkg_url = "https://sensu.global.ssl.fastly.net/freebsd/FreeBSD:10:amd64/sensu/sensu-${pkg_url_version}.txz"
      } else {
        $_pkg_url = $::sensu::pkg_url
      }

      $pkg_source = "/tmp/sensu-${pkg_url_version}.txz"
      $pkg_require = "Remote_file[${pkg_title}]"

      remote_file { $pkg_title:
        ensure   => present,
        path     => $pkg_source,
        source   => $_pkg_url,
        checksum => $::sensu::package_checksum,
      }
    }
    'RedHat': {
      $default_dir = '/etc/default'
      $pkg_title = 'sensu'
      $pkg_name = 'sensu'
      $pkg_version = $::sensu::version
      $pkg_source = undef
      $pkg_provider = undef

      if $::sensu::manage_repo {
        class { '::sensu::repo::yum': }
      }
      $pkg_require = undef
    }

    'windows': {
      $repo_require = undef

      # $pkg_version is passed to Package[sensu] { ensure }.  The Windows MSI
      # provider translates hyphens to dots, e.g. '0.29.0-11' maps to
      # '0.29.0.11' on the system.  This mapping is necessary to converge.
      $pkg_version = template('sensu/sensu-windows-package-version.erb')
      # The version used to construct the download URL.
      $pkg_url_version = $::sensu::version ? {
        'installed' => 'latest',
        default     => $::sensu::version,
      }
      # The title used for consistent relationships in the Puppet catalog
      $pkg_title = $::sensu::windows_package_title
      # The name used by the provider to compare to Windows Add/Remove programs.
      $pkg_name = $::sensu::windows_package_name

      # The user can override the computation of the source URL.  This URL is
      # used with the remote_file resource, it is not used with the chocolatey
      # package provider.
      if $::sensu::windows_pkg_url {
        $pkg_url = $::sensu::windows_pkg_url
      } else {
        # The OS Release specific sub-folder
        $os_release = $facts['os']['release']['major']
        # e.g. '2012 R2' => '2012r2'
        $pkg_url_dir = template('sensu/sensu-version.erb')
        $pkg_arch = $facts['os']['architecture']
        $pkg_url = "${::sensu::windows_repo_prefix}/${pkg_url_dir}/sensu-${pkg_url_version}-${pkg_arch}.msi"
      }

      if $::sensu::windows_package_provider == 'chocolatey' {
        $pkg_provider = 'chocolatey'
        if $::sensu::windows_choco_repo {
          $pkg_source = $::sensu::windows_choco_repo
        } else {
          $pkg_source = undef
        }
        $pkg_require = undef
      } else {
        # Use Puppet's default package provider
        $pkg_provider = undef
        # Where the MSI is downloaded to and installed from.
        $pkg_source = "C:\\Windows\\Temp\\sensu-${pkg_url_version}.msi"
        $pkg_require = "Remote_file[${pkg_title}]"

        # path matches Package[sensu] { source => $pkg_source }
        remote_file { $pkg_title:
          ensure   => present,
          path     => $pkg_source,
          source   => $pkg_url,
          checksum => $::sensu::package_checksum,
        }
      }
    }
    default: { fail("${::osfamily} not supported yet") }
  }

  package { $pkg_title:
    ensure   => $pkg_version,
    name     => $pkg_name,
    source   => $pkg_source,
    require  => $pkg_require,
    provider => $pkg_provider,
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
    file { "${default_dir}/sensu":
      ensure  => file,
      content => template("${module_name}/sensu.erb"),
      owner   => '0',
      group   => '0',
      mode    => '0444',
      require => Package[$pkg_title],
    }
  }

  file { [ $::sensu::conf_dir, "${::sensu::conf_dir}/handlers", "${::sensu::conf_dir}/checks", "${::sensu::conf_dir}/filters", "${::sensu::conf_dir}/extensions", "${::sensu::conf_dir}/mutators" ]:
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
    file { "${::sensu::etc_dir}/handlers":
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

  file { ["${::sensu::etc_dir}/extensions", "${::sensu::etc_dir}/extensions/handlers"]:
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
    file { "${::sensu::etc_dir}/mutators":
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
    file { "${::sensu::etc_dir}/plugins":
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

  file { "${::sensu::etc_dir}/config.json": ensure => absent }
}
