# Class: examplesensu::plugins
#
#
class examplesensu::plugins {
  package { 'nagios-plugins-basic':
    ensure => installed,
  }
  sensu::plugin {
    'puppet:///modules/examplesensu/plugins/check_mem.sh':;
    'puppet:///modules/examplesensu/plugins/check-memcached-stats.rb':;
    'puppet:///modules/examplesensu/plugins/check-procs.rb':;
    'puppet:///modules/examplesensu/plugins/mysql-graphite.rb':;
  }

}