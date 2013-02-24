# = Class: sensu::package
#
# Installs the Sensu packages
#
# == Parameters
#

class sensu::package {

  include sensu::repo

  package { 'sensu':
    ensure => latest,
  }

  sensu_clean_config { $::fqdn: }
}
