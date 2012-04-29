class sensu::package {
  package { 'sensu':
    ensure => latest,
  }

  sensu_clean_config { $::fqdn: }
}
