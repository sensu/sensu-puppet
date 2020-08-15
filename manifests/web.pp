# @summary Manage Sensu Go Web
#
# Class to manage the Sensu Go Web.
#
# @example
#   include sensu::web
#
# @param revision
#   Git revision of Sensu Go Web to download with git
#   This can be a git tag, branch of commit SHA
# @param source
#   Sensu Go Web git repo source URL
# @param install_dir
#   Path of where to install Sensu web
# @param port
#   Port to use for Sensu Web
#   Default is 9080
#   Changing the value below 1024 requires setting service_user=root and service_group=root
# @param service_user
#   The user to run sensu-web service as
#   Defaults to value defined for sensu::user parameter
# @param service_group
#   The group to run sensu-web service as
#   Defaults to value defined for sensu::group parameter
#
class sensu::web (
  Optional[String] $revision = 'v1.0.1',
  String $source = 'https://github.com/sensu/web.git',
  Stdlib::Absolutepath $install_dir = '/opt/sensu-web',
  Stdlib::Port $port = 9080,
  Optional[String] $service_user = undef,
  Optional[String] $service_group = undef,
) {

  if $facts['service_provider'] != 'systemd' {
    fail('Class sensu::web is only supported on systems that support systemd')
  }

  include sensu
  include sensu::common::user
  include git
  include nodejs
  include yarn

  Package['nodejs'] -> Package['yarn']

  $user = $sensu::sensu_user
  $group = $sensu::sensu_group
  $_service_user = pick($service_user, $user)
  $_service_group = pick($service_group, $group)
  $api_url = $sensu::api_url

  file { 'sensu-web-dir':
    ensure => 'directory',
    path   => $install_dir,
    owner  => $user,
    group  => $group,
    mode   => '0755',
    before => Vcsrepo['sensu-web'],
  }

  vcsrepo { 'sensu-web':
    ensure   => 'latest',
    path     => $install_dir,
    provider => 'git',
    revision => $revision,
    source   => $source,
    user     => $user,
    notify   => Exec['sensu-web-touch-install'],
  }

  exec { 'sensu-web-touch-install':
    path        => '/usr/bin:/bin',
    command     => "touch ${install_dir}/.install",
    refreshonly => true,
    user        => $user,
    before      => Exec['sensu-web-install'],
  }
  exec { 'sensu-web-install':
    path    => '/usr/bin:/bin:/usr/sbin:/sbin',
    command => "yarn install && rm -f ${install_dir}/.install",
    cwd     => $install_dir,
    onlyif  => "test -f ${install_dir}/.install",
    timeout => 0,
    user    => $user,
    require => Package['yarn'],
  }

  systemd::unit_file { 'sensu-web.service':
    content => template('sensu/sensu-web.service.erb'),
    notify  => Service['sensu-web'],
  }

  if versioncmp($facts['puppetversion'],'6.1.0') < 0 {
    # Puppet 5 does not execute 'systemctl daemon-reload' automatically (https://tickets.puppetlabs.com/browse/PUP-3483)
    # and camptocamp/systemd only creates this relationship when managing the service
    Class['systemd::systemctl::daemon_reload'] -> Service['sensu-web']
  }

  service { 'sensu-web':
    ensure    => 'running',
    enable    => true,
    subscribe => Exec['sensu-web-install'],
  }
}
